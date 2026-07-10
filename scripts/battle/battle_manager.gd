## BattleManager — orchestrates full battle lifecycle.
## Attached to battle.tscn root (Node). Creates dependencies in _setup().
class_name BattleManager
extends Node

# ─── Signals ──────────────────────────────────────────────────────────────────
signal battle_started
signal turn_started(actor: BattleActor)
signal turn_finished(actor: BattleActor)
signal battle_finished(outcome: BattleEnums.BattleOutcome, result: BattleResult)

# ─── Constants ────────────────────────────────────────────────────────────────
const MAX_TURNS := 100

# ─── Dependencies (set in _setup_dependencies) ────────────────────────────────
var _state_machine: BattleStateMachine = null
var _turn_manager: TurnManager = null
var _enemy_ai: EnemyAI = null

# ─── Runtime State ────────────────────────────────────────────────────────────
var _party: Array[BattleActor] = []
var _enemies: Array[BattleActor] = []
var _all_actors: Array[BattleActor] = []
var _turn_count: int = 0
var _enable_debug_logs: bool = true
var _battle_result: BattleResult = null

# ─── Lifecycle ────────────────────────────────────────────────────────────────
func _ready() -> void:
	_setup_dependencies()

# ─── Public API ───────────────────────────────────────────────────────────────
## ---- Player Action Entry Point (UI / Headless Tests) --------------------------
## Submit a player action for the current turn. Returns true if accepted.
## Rejected when: not PLAYER_TURN, no current actor, no living target, invalid action.
func request_player_action(action_type: BattleEnums.CommandType) -> bool:
	if _state_machine.current_state != BattleStateMachine.State.PLAYER_TURN:
		return false

	var actor := _turn_manager.current_actor()
	if actor == null:
		return false

	var cmd: BattleCommand
	match action_type:
		BattleEnums.CommandType.ATTACK:
			var target := _first_living(_enemies)
			if target == null:
				return false
			cmd = BattleCommand.basic_attack(actor, target)
		BattleEnums.CommandType.ITEM:
			# ITEM usage handled in two phases:
			# Phase 1: player selects item+target in UI.
			# Phase 2: UI calls request_player_action_with_item().
			# Single-phase ITEM (no sub-menu) not supported — reject.
			return false
		_:
			return false  # other commands not implemented yet

	_pending_command = cmd
	_state_machine.transition_to(BattleStateMachine.State.EXECUTING_ACTION)
	return true

## Submit a specific item command. Called by UI after item+target selection.
func request_player_action_with_item(item_id: StringName, target: BattleActor) -> bool:
	if _state_machine.current_state != BattleStateMachine.State.PLAYER_TURN:
		return false
	var actor := _turn_manager.current_actor()
	if actor == null:
		return false

	var inventory := InventoryManager.new()
	if not inventory.can_use_item(item_id, target):
		return false

	var cmd := BattleCommand.new(actor, [target], BattleEnums.CommandType.ITEM)
	cmd.item_id = item_id
	_pending_command = cmd
	_state_machine.transition_to(BattleStateMachine.State.EXECUTING_ACTION)
	return true

## ---- Public Accessors ---------------------------------------------------------
func get_living_party() -> Array[BattleActor]:
	return _living_actors(_party)

func get_living_enemies() -> Array[BattleActor]:
	return _living_actors(_enemies)

func get_current_actor() -> BattleActor:
	return _turn_manager.current_actor()

func get_party_snapshot() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for actor in _party:
		result.append({
			"character_id": actor.actor_id,
			"current_hp": actor.current_hp,
			"current_sp": actor.current_sp,
		})
	return result

## ---- Battle Start -------------------------------------------------------------
func start_battle(party: Array[BattleActor], enemies: Array[BattleActor]) -> void:
	_party = party
	_enemies = enemies
	_all_actors = _party + _enemies
	_turn_count = 0
	_battle_result = null

	_debug_log("Battle Started")
	EventBus.emit_event("battle_started", {})
	battle_started.emit()

	_state_machine.transition_to(BattleStateMachine.State.INITIALIZING)

# ─── Dependency Setup ─────────────────────────────────────────────────────────
func _setup_dependencies() -> void:
	_state_machine = BattleStateMachine.new()
	_turn_manager = TurnManager.new()
	_enemy_ai = EnemyAI.new()
	_state_machine.state_changed.connect(_on_state_changed)

# ─── State Change Handler ─────────────────────────────────────────────────────
func _on_state_changed(_old_state: BattleStateMachine.State, new_state: BattleStateMachine.State) -> void:
	match new_state:
		BattleStateMachine.State.INITIALIZING:
			_on_initializing()
		BattleStateMachine.State.PLAYER_TURN:
			_on_player_turn()
		BattleStateMachine.State.ENEMY_TURN:
			_on_enemy_turn()
		BattleStateMachine.State.EXECUTING_ACTION:
			_on_executing_action()
		BattleStateMachine.State.CHECK_RESULT:
			_on_check_result()
		BattleStateMachine.State.VICTORY, BattleStateMachine.State.DEFEAT:
			_on_battle_end(new_state)
		BattleStateMachine.State.CLEANUP:
			_on_cleanup()

# ─── State Handlers ───────────────────────────────────────────────────────────
func _on_initializing() -> void:
	_turn_manager.initialize(_all_actors)
	# first actor determines if player_turn or enemy_turn
	var first := _turn_manager.next_turn()
	if first == null:
		_debug_log("No living actors — aborting.")
		_state_machine.transition_to(BattleStateMachine.State.DEFEAT)
		return
	if first.team == BattleEnums.Team.PLAYER:
		_state_machine.transition_to(BattleStateMachine.State.PLAYER_TURN)
	else:
		_state_machine.transition_to(BattleStateMachine.State.ENEMY_TURN)

func _on_player_turn() -> void:
	_turn_count += 1
	if _turn_count > MAX_TURNS:
		_push_max_turns_abort()
		return

	var actor := _turn_manager.current_actor()
	if actor == null:
		_state_machine.transition_to(BattleStateMachine.State.CHECK_RESULT)
		return

	_debug_log("%s Turn" % actor.display_name)
	EventBus.emit_event("turn_started", {"actor_id": actor.actor_id, "display_name": actor.display_name})
	turn_started.emit(actor)
	# Stops here. Caller (UI, headless test) must submit action via request_player_action().

func _on_enemy_turn() -> void:
	_turn_count += 1
	if _turn_count > MAX_TURNS:
		_push_max_turns_abort()
		return

	var actor := _turn_manager.current_actor()
	if actor == null:
		_state_machine.transition_to(BattleStateMachine.State.CHECK_RESULT)
		return

	_debug_log("%s Turn" % actor.display_name)
	EventBus.emit_event("turn_started", {"actor_id": actor.actor_id, "display_name": actor.display_name})
	turn_started.emit(actor)

	var living_players := _living_actors(_party)
	if living_players.is_empty():
		_state_machine.transition_to(BattleStateMachine.State.CHECK_RESULT)
		return

	var cmd := _enemy_ai.choose_command(actor, living_players)
	_pending_command = cmd
	_state_machine.transition_to(BattleStateMachine.State.EXECUTING_ACTION)

# ─── Pending command (set before EXECUTING_ACTION) ────────────────────────────
var _pending_command: BattleCommand = null

func _on_executing_action() -> void:
	var cmd := _pending_command
	_pending_command = null

	if cmd == null:
		_state_machine.transition_to(BattleStateMachine.State.CHECK_RESULT)
		return

	var result := _execute_command(cmd)
	if _battle_result == null:
		_battle_result = result
	else:
		# append target results from subsequent commands (multi-action battle summary)
		for target_result in result.target_results:
			_battle_result.add_target_result(target_result.target, target_result.damage, target_result.healing, target_result.is_critical, target_result.is_missed, target_result.status_applied)

	_turn_manager.strip_defeated()

	var actor := cmd.actor
	_debug_log("%s attacks %s" % [actor.display_name, _target_names(cmd.targets)])
	EventBus.emit_event("command_executed", {"actor_id": actor.actor_id})

	turn_finished.emit(actor)
	_state_machine.transition_to(BattleStateMachine.State.CHECK_RESULT)

func _on_check_result() -> void:
	# check victory: all enemies defeated
	if _all_defeated(_enemies):
		_state_machine.transition_to(BattleStateMachine.State.VICTORY)
		return
	# check defeat: all party defeated
	if _all_defeated(_party):
		_state_machine.transition_to(BattleStateMachine.State.DEFEAT)
		return
	# next turn
	var next_actor := _turn_manager.next_turn()
	if next_actor == null:
		_state_machine.transition_to(BattleStateMachine.State.DEFEAT)
		return
	if next_actor.team == BattleEnums.Team.PLAYER:
		_state_machine.transition_to(BattleStateMachine.State.PLAYER_TURN)
	else:
		_state_machine.transition_to(BattleStateMachine.State.ENEMY_TURN)

func _on_battle_end(new_state: BattleStateMachine.State) -> void:
	var outcome: BattleEnums.BattleOutcome
	match new_state:
		BattleStateMachine.State.VICTORY:
			outcome = BattleEnums.BattleOutcome.VICTORY
			_debug_log("Victory")
			_process_victory_rewards()
		BattleStateMachine.State.DEFEAT:
			outcome = BattleEnums.BattleOutcome.DEFEAT
			_debug_log("Defeat")

	# ensure a battle result exists
	if _battle_result == null:
		_battle_result = BattleResult.new()

	EventBus.emit_event("battle_finished", {"outcome": outcome})
	battle_finished.emit(outcome, _battle_result)
	_state_machine.transition_to(BattleStateMachine.State.CLEANUP)

func _on_cleanup() -> void:
	_store_party_snapshots()
	_state_machine.transition_to(BattleStateMachine.State.FINISHED)

# ─── Command Execution ────────────────────────────────────────────────────────
func _execute_command(cmd: BattleCommand) -> BattleResult:
	var result := BattleResult.new(cmd.actor, cmd)

	for target in cmd.targets:
		if target.is_defeated():
			continue

		match cmd.command_type:
			BattleEnums.CommandType.ATTACK, BattleEnums.CommandType.SKILL:
				var calc := _calc_damage_for_command(cmd.actor, target, cmd)
				var damage := calc.final_damage

				if calc.is_missed:
					result.add_target_result(target, 0, 0, false, true)
					_debug_log("Missed %s" % target.display_name)
				else:
					var actual := target.take_damage(damage)
					var was_defeated := target.is_defeated()
					result.add_target_result(target, actual, 0, calc.is_critical, false)
					_debug_log("Damage: %d | %s HP: %d" % [actual, target.display_name, target.current_hp])
					EventBus.emit_event("damage_dealt", {
						"target_id": target.actor_id,
						"damage": actual,
						"is_critical": calc.is_critical,
					})
					if was_defeated:
						_debug_log("%s defeated" % target.display_name)
						EventBus.emit_event("actor_died", {"actor_id": target.actor_id, "display_name": target.display_name})

			BattleEnums.CommandType.ITEM:
				_execute_item_command(cmd, target, result)

			BattleEnums.CommandType.GUARD:
				cmd.actor.is_guarding = true
				_debug_log("%s guards" % cmd.actor.display_name)

			BattleEnums.CommandType.FLEE:
				# FLEE not implemented in M5.1 — treated as no-op
				_debug_log("%s attempts to flee (no-op in M5.1)" % cmd.actor.display_name)

	return result

func _calc_damage_for_command(attacker: BattleActor, defender: BattleActor, cmd: BattleCommand) -> DamageCalculator.DamageCalcResult:
	var power: int = 10  # default basic attack power
	var element: BattleEnums.Element = BattleEnums.Element.NEUTRAL

	if cmd.skill != null:
		power = cmd.skill.power
		# simple element parsing from string — full enum mapping deferred
		element = _parse_element(cmd.skill.element)

	match _skill_type(cmd):
		"physical":
			return DamageCalculator.calculate_physical_damage(attacker, defender, power, element)
		"magical":
			return DamageCalculator.calculate_magical_damage(attacker, defender, power, element)
		_:
			return DamageCalculator.calculate_physical_damage(attacker, defender, power, element)

func _skill_type(cmd: BattleCommand) -> String:
	if cmd.skill != null:
		return cmd.skill.skill_type if not cmd.skill.skill_type.is_empty() else "physical"
	return "physical"

func _parse_element(element_str: String) -> BattleEnums.Element:
	match element_str.to_lower():
		"fire":
			return BattleEnums.Element.FIRE
		"water":
			return BattleEnums.Element.WATER
		"wind":
			return BattleEnums.Element.WIND
		"earth":
			return BattleEnums.Element.EARTH
		"lightning":
			return BattleEnums.Element.LIGHTNING
		"ice":
			return BattleEnums.Element.ICE
		"light":
			return BattleEnums.Element.LIGHT
		"dark":
			return BattleEnums.Element.DARK
		_:
			return BattleEnums.Element.NEUTRAL

# ─── Helpers ──────────────────────────────────────────────────────────────────
func _first_living(actors: Array[BattleActor]) -> BattleActor:
	for a in actors:
		if a.is_alive():
			return a
	return null

func _living_actors(actors: Array[BattleActor]) -> Array[BattleActor]:
	var result: Array[BattleActor] = []
	for a in actors:
		if a.is_alive():
			result.append(a)
	return result

func _all_defeated(actors: Array[BattleActor]) -> bool:
	for a in actors:
		if a.is_alive():
			return false
	return true

func _target_names(targets: Array[BattleActor]) -> String:
	var names: Array[String] = []
	for t in targets:
		names.append(t.display_name)
	return ", ".join(names)

# ─── Debug Logging ────────────────────────────────────────────────────────────
func _debug_log(msg: String) -> void:
	if _enable_debug_logs:
		print("[Battle] " + msg)

# ─── Max Turns Guard ──────────────────────────────────────────────────────────
# ─── Item Command Execution ───────────────────────────────────────────────────
func _execute_item_command(cmd: BattleCommand, target: BattleActor, result: BattleResult) -> void:
	var inventory := InventoryManager.new()
	var item_id: StringName = cmd.item_id
	if item_id == &"":
		_debug_log("Item use failed: no item_id on command")
		return

	if not inventory.use_item(item_id, target):
		_debug_log("Item use failed: %s on %s" % [item_id, target.display_name])
		return

	var item_res := inventory.get_item_resource(item_id)
	var healing := 0
	if item_res != null:
		for effect: ItemEffect in item_res.consumable_effects:
			if effect.effect_type == ItemEffect.EffectType.HEAL_HP:
				healing = effect.value  # actual amount already applied by use_item
	_debug_log("Used %s on %s" % [item_res.item_name if item_res else str(item_id), target.display_name])
	result.add_target_result(target, 0, healing, false, false)

# ─── Victory Rewards ──────────────────────────────────────────────────────────
func _process_victory_rewards() -> void:
	var total_exp := 0
	var total_gold := 0
	var drops: Array[Dictionary] = []

	for enemy in _enemies:
		total_exp += _get_enemy_exp(enemy)
		total_gold += _get_enemy_gold(enemy)
		drops.append_array(_roll_enemy_drops(enemy))

	# Distribute rewards
	for actor in _party:
		PartyState.add_exp(actor.actor_id, total_exp)
	PartyState.add_gold(total_gold)
	for drop in drops:
		PartyState.add_item(drop["item_id"], drop.get("quantity", 1))

	EventBus.emit_event("battle_victory_rewards", {
		"exp": total_exp,
		"gold": total_gold,
		"items": drops,
	})

	_debug_log("Rewards: %d EXP, %d gold, %d items" % [total_exp, total_gold, drops.size()])

func _get_enemy_exp(enemy: BattleActor) -> int:
	for s in Engine.get_singleton_list():
		if str(s) == "Database":
			var db := Engine.get_singleton(s)
			var res: Resource = db.get_enemy(enemy.actor_id)
			if res is EnemyResource:
				return res.exp_reward
			break
	return 0

func _get_enemy_gold(_enemy: BattleActor) -> int:
	# Placeholder: 10 gold per enemy. Replace with EnemyResource.gold_reward if added.
	return 10

func _roll_enemy_drops(enemy: BattleActor) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for s in Engine.get_singleton_list():
		if str(s) == "Database":
			var db := Engine.get_singleton(s)
			var res: Resource = db.get_enemy(enemy.actor_id)
			if res is EnemyResource:
				for drop in res.item_drops:
					var chance: float = drop.get("chance", 0.0)
					if randf() <= chance:
						result.append({
							"item_id": drop.get("item_id", ""),
							"quantity": drop.get("quantity", 1),
						})
			break
	return result

# ─── Snapshots ────────────────────────────────────────────────────────────────
func _store_party_snapshots() -> void:
	PartyState.snapshots = get_party_snapshot()

func _push_max_turns_abort() -> void:
	push_error("BattleManager: exceeded MAX_TURNS (%d). Aborting." % MAX_TURNS)
	_battle_result = BattleResult.new()
	EventBus.emit_event("battle_finished", {"outcome": BattleEnums.BattleOutcome.ABORTED})
	battle_finished.emit(BattleEnums.BattleOutcome.ABORTED, _battle_result)
	_state_machine.transition_to(BattleStateMachine.State.CLEANUP)