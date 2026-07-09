## BattleUIController — coordinates UI ↔ BattleManager bridge.
## Lightweight. Only handles CommandMenu lifecycle and action forwarding.
class_name BattleUIController
extends Node

# ─── @onready ─────────────────────────────────────────────────────────────────
@onready var party_panel: PartyPanel = %PartyPanel
@onready var enemy_panel: EnemyPanel = %EnemyPanel
@onready var command_menu: CommandMenu = %CommandMenu
@onready var battle_log: BattleLog = %BattleLog

# ─── State ────────────────────────────────────────────────────────────────────
var _battle_manager: BattleManager = null

# ─── Lifecycle ────────────────────────────────────────────────────────────────
func _ready() -> void:
	_battle_manager = _find_battle_manager()
	if _battle_manager == null:
		push_error("BattleUIController: BattleManager not found in parent.")
		return

	_battle_manager.turn_started.connect(_on_turn_started)
	_battle_manager.battle_finished.connect(_on_battle_finished)
	command_menu.action_requested.connect(_on_action_requested)

	command_menu.disable()

func _exit_tree() -> void:
	if _battle_manager != null:
		_battle_manager.turn_started.disconnect(_on_turn_started)
		_battle_manager.battle_finished.disconnect(_on_battle_finished)

# ─── Signal Handlers ──────────────────────────────────────────────────────────
func _on_turn_started(actor: BattleActor) -> void:
	party_panel.refresh_all()
	enemy_panel.refresh_all()

	if actor.is_player():
		battle_log.add_entry("Your turn!", Color.LIGHT_GREEN)
		command_menu.enable()
	else:
		battle_log.add_entry("Enemy turn...", Color.GRAY)
		command_menu.disable()

func _on_action_requested(action: BattleEnums.CommandType) -> void:
	if _battle_manager == null:
		return
	var accepted := _battle_manager.request_player_action(action)
	if accepted:
		command_menu.disable()

func _on_battle_finished(outcome: BattleEnums.BattleOutcome, _result: BattleResult) -> void:
	command_menu.disable()
	match outcome:
		BattleEnums.BattleOutcome.VICTORY:
			battle_log.add_entry("Victory!", Color.GOLD)
		BattleEnums.BattleOutcome.DEFEAT:
			battle_log.add_entry("Defeat...", Color.RED)
		_:
			battle_log.add_entry("Battle ended.", Color.GRAY)

# ─── Private ──────────────────────────────────────────────────────────────────
func _find_battle_manager() -> BattleManager:
	var parent := get_parent()
	if parent is BattleManager:
		return parent
	return null