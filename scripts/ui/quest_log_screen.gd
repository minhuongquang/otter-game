## QuestLogScreen — shows available, active, and completed quests.
## Reads from QuestManager.instance(). Never writes quest state directly.
class_name QuestLogScreen
extends Control

# ─── Signals ──────────────────────────────────────────────────────────────────
signal closed

# ─── @onready ─────────────────────────────────────────────────────────────────
@onready var tab_bar: TabBar = %TabBar
@onready var quest_list: VBoxContainer = %QuestList
@onready var detail_panel: Control = %DetailPanel
@onready var title_label: Label = %TitleLabel
@onready var description_label: Label = %DescriptionLabel
@onready var stage_label: Label = %StageLabel
@onready var objectives_list: VBoxContainer = %ObjectivesList
@onready var rewards_list: VBoxContainer = %RewardsList
@onready var status_label: Label = %StatusLabel
@onready var close_button: Button = %CloseButton

# ─── State ────────────────────────────────────────────────────────────────────
var _qm: QuestManager = null
var _current_tab: int = 0  # 0=Available, 1=Active, 2=Completed
var _selected_quest_id: String = ""

# ─── Lifecycle ────────────────────────────────────────────────────────────────
func _ready() -> void:
	_qm = QuestManager.instance()
	tab_bar.tab_changed.connect(_on_tab_changed)
	close_button.pressed.connect(_on_close_pressed)
	# Listen for quest events to auto-refresh
	EventBus.listen("quest_started", _on_quest_event)
	EventBus.listen("quest_progress_updated", _on_quest_event)
	EventBus.listen("quest_stage_advanced", _on_quest_event)
	EventBus.listen("quest_completed", _on_quest_event)
	EventBus.listen("quest_rewarded", _on_quest_event)
	_refresh()

func _exit_tree() -> void:
	EventBus.unlisten("quest_started", _on_quest_event)
	EventBus.unlisten("quest_progress_updated", _on_quest_event)
	EventBus.unlisten("quest_stage_advanced", _on_quest_event)
	EventBus.unlisten("quest_completed", _on_quest_event)
	EventBus.unlisten("quest_rewarded", _on_quest_event)

# ─── Refresh ──────────────────────────────────────────────────────────────────
func _refresh() -> void:
	_build_list()
	_update_detail()

func _build_list() -> void:
	for child in quest_list.get_children():
		child.queue_free()

	var quests: Array[Dictionary]
	match _current_tab:
		0:
			quests = _qm.get_available_quests()
		1:
			quests = _qm.get_active_quests()
		2:
			var completed_ids := _qm.get_completed_quests()
			for quest_id in completed_ids:
				var res: QuestResource = _resolve(quest_id)
				if res != null:
					quests.append({"quest_id": quest_id, "title": res.title})

	for quest in quests:
		var btn := Button.new()
		btn.text = quest["title"]
		btn.pressed.connect(_on_quest_selected.bind(quest["quest_id"]))
		quest_list.add_child(btn)

func _update_detail() -> void:
	if _selected_quest_id == "":
		title_label.text = ""
		description_label.text = ""
		stage_label.text = ""
		for child in objectives_list.get_children():
			child.queue_free()
		for child in rewards_list.get_children():
			child.queue_free()
		status_label.text = ""
		return

	var res: QuestResource = _resolve(_selected_quest_id)
	if res == null:
		return

	title_label.text = res.title
	description_label.text = res.description

	var state: int = _qm.get_state(_selected_quest_id)
	match state:
		PartyState.QuestState.AVAILABLE:
			status_label.text = "Available"
		PartyState.QuestState.ACTIVE:
			status_label.text = "In Progress"
		PartyState.QuestState.READY_TO_COMPLETE:
			status_label.text = "Ready to Turn In"
		PartyState.QuestState.COMPLETED, PartyState.QuestState.REWARDED:
			status_label.text = "Completed"

	# Stage info
	var stage_idx: int = _qm.get_current_stage(_selected_quest_id)
	if stage_idx >= 0 and stage_idx < res.stages.size():
		var stage: QuestStageResource = res.stages[stage_idx]
		stage_label.text = "Stage %d/%d: %s" % [stage_idx + 1, res.stages.size(), stage.description]
	else:
		stage_label.text = ""

	# Objectives
	for child in objectives_list.get_children():
		child.queue_free()
	if stage_idx >= 0 and stage_idx < res.stages.size():
		var stage: QuestStageResource = res.stages[stage_idx]
		for objective in stage.objectives:
			var progress: int = _qm.get_objective_progress(_selected_quest_id, objective.objective_id)
			var label := Label.new()
			if progress >= objective.required_count:
				label.text = "✓ %s (%d/%d)" % [objective.description, progress, objective.required_count]
			else:
				label.text = "○ %s (%d/%d)" % [objective.description, progress, objective.required_count]
			objectives_list.add_child(label)

	# Rewards
	for child in rewards_list.get_children():
		child.queue_free()
	if state == PartyState.QuestState.AVAILABLE or state == PartyState.QuestState.READY_TO_COMPLETE:
		if res.rewards.has("exp") and int(res.rewards.exp) > 0:
			var label := Label.new()
			label.text = "EXP: +%d" % int(res.rewards.exp)
			rewards_list.add_child(label)
		if res.rewards.has("gold") and int(res.rewards.gold) > 0:
			var label := Label.new()
			label.text = "Gold: +%d" % int(res.rewards.gold)
			rewards_list.add_child(label)
		if res.rewards.has("items"):
			for item_entry in res.rewards.items:
				var label := Label.new()
				var item_id: String = item_entry.get("id", "???")
				var qty: int = item_entry.get("qty", 1)
				label.text = "Item: %s x%d" % [item_id, qty]
				rewards_list.add_child(label)

# ─── Signal Handlers ──────────────────────────────────────────────────────────
func _on_tab_changed(tab: int) -> void:
	_current_tab = tab
	_selected_quest_id = ""
	_refresh()

func _on_quest_selected(quest_id: String) -> void:
	_selected_quest_id = quest_id
	_update_detail()

func _on_quest_event(_data: Dictionary) -> void:
	_refresh.call_deferred()

func _on_close_pressed() -> void:
	closed.emit()
	queue_free()

# ─── Helpers ──────────────────────────────────────────────────────────────────
func _resolve(quest_id: String) -> QuestResource:
	var res: Resource = Database.get_quest(quest_id)
	if res is QuestResource:
		return res
	return null