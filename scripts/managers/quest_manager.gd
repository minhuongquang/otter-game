## QuestManager — single-instance service for quest lifecycle management.
## Uses QuestManager.instance() to access. All persistent state in PartyState.
## Event-driven: listens to EventBus for objective progress, never called directly by gameplay systems.
class_name QuestManager
extends RefCounted

# ─── Singleton ────────────────────────────────────────────────────────────────
static var _instance: QuestManager = null
static var _listeners_registered: bool = false

static func instance() -> QuestManager:
	if _instance == null:
		_instance = QuestManager.new()
		_instance._initialize()
	return _instance

# ─── Initialization ───────────────────────────────────────────────────────────
func _initialize() -> void:
	_ensure_listeners()

func _ensure_listeners() -> void:
	if _listeners_registered:
		return
	EventBus.listen("enemy_defeated", _on_enemy_defeated)
	EventBus.listen("item_added", _on_item_added)
	EventBus.listen("npc_talked", _on_npc_talked)
	EventBus.listen("area_entered", _on_area_entered)
	EventBus.listen("level_changed", _on_level_changed)
	EventBus.listen("quest_completed", _on_quest_completed)
	_listeners_registered = true

# ─── Quest Lifecycle ──────────────────────────────────────────────────────────
## Accept an AVAILABLE quest. Moves to ACTIVE, initializes stage 0.
func accept_quest(quest_id: String) -> bool:
	if not can_accept(quest_id):
		push_warning("QuestManager: cannot accept quest '%s'" % quest_id)
		return false
	_set_state(quest_id, PartyState.QuestState.ACTIVE)
	PartyState.quests[quest_id]["current_stage"] = 0
	PartyState.quests[quest_id]["objective_progress"] = {}
	PartyState.quests[quest_id]["reward_claimed"] = false
	EventBus.emit_event("quest_started", {"quest_id": quest_id})
	return true

## Advance to the next stage. If last stage, set READY_TO_COMPLETE.
func advance_stage(quest_id: String) -> bool:
	var state := get_state(quest_id)
	if state != PartyState.QuestState.ACTIVE:
		return false
	var res := _resolve(quest_id)
	if res == null:
		return false
	var q: Dictionary = PartyState.quests[quest_id]
	var next_stage: int = q.get("current_stage", 0) + 1
	if next_stage >= res.stages.size():
		_set_state(quest_id, PartyState.QuestState.READY_TO_COMPLETE)
		EventBus.emit_event("quest_stage_advanced", {"quest_id": quest_id, "stage_index": next_stage, "is_last": true})
		return true
	q["current_stage"] = next_stage
	q["objective_progress"] = {}  # reset progress for new stage
	EventBus.emit_event("quest_stage_advanced", {"quest_id": quest_id, "stage_index": next_stage, "is_last": false})
	return true

## Complete a READY_TO_COMPLETE quest. Moves to COMPLETED.
func complete_quest(quest_id: String) -> bool:
	var state := get_state(quest_id)
	if state != PartyState.QuestState.READY_TO_COMPLETE:
		push_warning("QuestManager: cannot complete quest '%s' — not READY_TO_COMPLETE" % quest_id)
		return false
	_set_state(quest_id, PartyState.QuestState.COMPLETED)
	PartyState.completed_quests.append(quest_id)
	EventBus.emit_event("quest_completed", {"quest_id": quest_id})
	return true

## Fail a quest. Not used in prototype.
func fail_quest(quest_id: String) -> bool:
	PartyState.quests.erase(quest_id)
	EventBus.emit_event("quest_failed", {"quest_id": quest_id})
	return true

## Claim rewards for a COMPLETED quest. Moves to REWARDED.
func claim_rewards(quest_id: String) -> bool:
	var state := get_state(quest_id)
	if state != PartyState.QuestState.COMPLETED:
		return false
	var res := _resolve(quest_id)
	if res == null:
		return false
	_distribute_rewards(res.rewards)
	_set_state(quest_id, PartyState.QuestState.REWARDED)
	PartyState.quests[quest_id]["reward_claimed"] = true
	EventBus.emit_event("quest_rewarded", {"quest_id": quest_id, "rewards": res.rewards})
	return true

# ─── Queries ──────────────────────────────────────────────────────────────────
func get_state(quest_id: String) -> int:
	if not PartyState.quests.has(quest_id):
		return PartyState.QuestState.LOCKED
	return PartyState.quests[quest_id].get("state", PartyState.QuestState.LOCKED)

func get_current_stage(quest_id: String) -> int:
	if not PartyState.quests.has(quest_id):
		return -1
	return PartyState.quests[quest_id].get("current_stage", 0)

func get_objective_progress(quest_id: String, objective_id: String) -> int:
	if not PartyState.quests.has(quest_id):
		return 0
	var progress: Dictionary = PartyState.quests[quest_id].get("objective_progress", {})
	return progress.get(objective_id, 0)

func is_completed(quest_id: String) -> bool:
	return quest_id in PartyState.completed_quests

func get_active_quests() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for quest_id in PartyState.quests:
		var state := get_state(quest_id)
		if state == PartyState.QuestState.ACTIVE or state == PartyState.QuestState.READY_TO_COMPLETE:
			var res := _resolve(quest_id)
			if res != null:
				result.append({
					"quest_id": quest_id,
					"title": res.title,
					"state": state,
					"current_stage": get_current_stage(quest_id),
					"total_stages": res.stages.size(),
				})
	return result

func get_available_quests() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	# Check all quests by scanning database folder — prototype: iterate known IDs
	# For M8, return active/in-progress only. Full registry deferred.
	for quest_id in PartyState.quests:
		if get_state(quest_id) == PartyState.QuestState.AVAILABLE:
			var res := _resolve(quest_id)
			if res != null:
				result.append({
					"quest_id": quest_id,
					"title": res.title,
					"state": PartyState.QuestState.AVAILABLE,
				})
	return result

func get_completed_quests() -> Array[String]:
	return PartyState.completed_quests.duplicate()

# ─── Validation ───────────────────────────────────────────────────────────────
func can_accept(quest_id: String) -> bool:
	var res := _resolve(quest_id)
	if res == null:
		return false
	# Check prerequisites
	for prereq in res.prerequisites:
		if not (prereq in PartyState.completed_quests):
			return false
	var state := get_state(quest_id)
	if state == PartyState.QuestState.LOCKED:
		# Auto-unlock: if all prerequisites met, set AVAILABLE
		_set_state(quest_id, PartyState.QuestState.AVAILABLE)
		state = PartyState.QuestState.AVAILABLE
	return state == PartyState.QuestState.AVAILABLE

func can_complete(quest_id: String) -> bool:
	return get_state(quest_id) == PartyState.QuestState.READY_TO_COMPLETE

# ─── Event Handlers ──────────────────────────────────────────────────────────
func _on_enemy_defeated(data: Dictionary) -> void:
	var enemy_id: String = data.get("enemy_id", "")
	if enemy_id == "":
		return
	_check_objectives_of_type(QuestObjectiveResource.ObjectiveType.DEFEAT_ENEMY, enemy_id)

func _on_item_added(data: Dictionary) -> void:
	var item_id: StringName = data.get("item_id", &"")
	if item_id == &"":
		return
	_check_objectives_of_type(QuestObjectiveResource.ObjectiveType.COLLECT_ITEM, str(item_id))

func _on_npc_talked(data: Dictionary) -> void:
	var npc_id: String = data.get("npc_id", "")
	if npc_id == "":
		return
	_check_objectives_of_type(QuestObjectiveResource.ObjectiveType.TALK_NPC, npc_id)

func _on_area_entered(data: Dictionary) -> void:
	var area_id: String = data.get("area_id", "")
	if area_id == "":
		return
	_check_objectives_of_type(QuestObjectiveResource.ObjectiveType.VISIT_AREA, area_id)

func _on_level_changed(_data: Dictionary) -> void:
	# REACH_LEVEL objective is checked against character level
	_check_objectives_of_type(QuestObjectiveResource.ObjectiveType.REACH_LEVEL, "")

func _on_quest_completed(data: Dictionary) -> void:
	# Auto-unlock quests whose prerequisites are now satisfied
	var completed_id: String = data.get("quest_id", "")
	if completed_id == "":
		return
	_unlock_available_quests()

# ─── Objective Checking ──────────────────────────────────────────────────────
func _check_objectives_of_type(objective_type: int, target_id: String) -> void:
	for quest_id in PartyState.quests:
		if get_state(quest_id) != PartyState.QuestState.ACTIVE:
			continue
		var res := _resolve(quest_id)
		if res == null:
			continue
		var q: Dictionary = PartyState.quests[quest_id]
		var stage_idx: int = q.get("current_stage", 0)
		if stage_idx < 0 or stage_idx >= res.stages.size():
			continue
		var stage: QuestStageResource = res.stages[stage_idx]
		for objective: QuestObjectiveResource in stage.objectives:
			if objective.objective_type != objective_type:
				continue
			# For REACH_LEVEL, target_id matching is deferred (check any character level)
			if objective_type != QuestObjectiveResource.ObjectiveType.REACH_LEVEL:
				if objective.target_id != target_id:
					continue
			else:
				# Check if any party member reached required level
				if not _any_party_member_meets_level(objective.required_count):
					continue
			_increment_objective(quest_id, objective)
			return  # one update per event

func _increment_objective(quest_id: String, objective: QuestObjectiveResource) -> void:
	var q: Dictionary = PartyState.quests[quest_id]
	var progress: Dictionary = q.get("objective_progress", {})
	var current: int = progress.get(objective.objective_id, 0)
	current += 1
	progress[objective.objective_id] = current
	q["objective_progress"] = progress

	EventBus.emit_event("quest_progress_updated", {
		"quest_id": quest_id,
		"objective_id": objective.objective_id,
		"current": current,
		"required": objective.required_count,
	})

	if current >= objective.required_count:
		_check_stage_completion(quest_id)

func _check_stage_completion(quest_id: String) -> void:
	var res := _resolve(quest_id)
	if res == null:
		return
	var q: Dictionary = PartyState.quests[quest_id]
	var stage_idx: int = q.get("current_stage", 0)
	if stage_idx < 0 or stage_idx >= res.stages.size():
		return
	var stage: QuestStageResource = res.stages[stage_idx]
	var progress: Dictionary = q.get("objective_progress", {})
	for objective: QuestObjectiveResource in stage.objectives:
		var current: int = progress.get(objective.objective_id, 0)
		if current < objective.required_count:
			return  # not all objectives complete
	# All objectives complete — advance
	advance_stage(quest_id)

func _any_party_member_meets_level(required_level: int) -> bool:
	for char_id in PartyState.character_progression:
		var level := PartyState.get_level(char_id)
		if level >= required_level:
			return true
	return false

# ─── Auto-Unlock ─────────────────────────────────────────────────────────────
func _unlock_available_quests() -> void:
	# Scan all known quests (from PartyState.quests + database) and unlock eligible ones
	# TODO: full quest registry for scanning all .tres files. For M8, quests are pre-registered.
	pass  # Deferred to quest registry milestone.

# ─── Rewards ─────────────────────────────────────────────────────────────────
func _distribute_rewards(rewards: Dictionary) -> void:
	if rewards.has("exp"):
		for char_id in PartyState.character_progression:
			PartyState.add_exp(char_id, int(rewards.exp))
	if rewards.has("gold"):
		PartyState.add_gold(int(rewards.gold))
	if rewards.has("items"):
		for item_entry in rewards.items:
			var item_id: String = item_entry.get("id", "")
			var qty: int = item_entry.get("qty", 1)
			if item_id != "":
				PartyState.add_item(StringName(item_id), qty)

# ─── Helpers ─────────────────────────────────────────────────────────────────
func _resolve(quest_id: String) -> QuestResource:
	var res: Resource = Database.get_quest(quest_id)
	if res is QuestResource:
		return res
	return null

func _set_state(quest_id: String, new_state: int) -> void:
	if not PartyState.quests.has(quest_id):
		PartyState.quests[quest_id] = {}
	PartyState.quests[quest_id]["state"] = new_state