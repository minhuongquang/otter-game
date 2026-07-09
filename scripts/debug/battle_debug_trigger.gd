## BattleDebugTrigger — temporary debug trigger for M5.1 headless battle.
## Press B during exploration to start a Hero vs Slime battle.
## Remove after M5.2 (UI-driven encounter flow replaces this).
extends Node

# ─── Private ──────────────────────────────────────────────────────────────────
var _battle_scene: Node = null

# ─── Input ────────────────────────────────────────────────────────────────────
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("battle_debug"):
		_trigger_battle()

# ─── Battle Lifecycle ─────────────────────────────────────────────────────────
func _trigger_battle() -> void:
	if _battle_scene != null and is_instance_valid(_battle_scene):
		# battle already active
		return

	var scene := get_tree().current_scene
	if scene == null:
		push_error("BattleDebugTrigger: no current scene to parent battle.")
		return

	var battle_tscn: PackedScene = load("res://scenes/battle/battle.tscn")
	if battle_tscn == null:
		push_error("BattleDebugTrigger: failed to load battle.tscn")
		return

	_battle_scene = battle_tscn.instantiate()
	scene.add_child(_battle_scene)

	var party := BattleFactory.create_party(["hero"], Database)
	var enemies := BattleFactory.create_enemies(["slime"], Database)

	if party.is_empty() or enemies.is_empty():
		push_error("BattleDebugTrigger: failed to create battle actors.")
		_cleanup_battle()
		return

	# Apply saved snapshots before battle
	PartyState.apply_to(party)

	var manager: BattleManager = _battle_scene as BattleManager
	if manager == null:
		push_error("BattleDebugTrigger: battle scene root is not BattleManager.")
		_cleanup_battle()
		return

	manager.battle_finished.connect(_on_battle_finished)
	manager.start_battle(party, enemies)

func _on_battle_finished(outcome: BattleEnums.BattleOutcome, result: BattleResult) -> void:
	print("[Debug] Battle finished: %s" % BattleEnums.BattleOutcome.keys()[outcome])
	print("[Debug] Total damage dealt: %d" % result.total_damage())

	# Update runtime party state after every battle
	if _battle_scene is BattleManager:
		PartyState.snapshots = (_battle_scene as BattleManager).get_party_snapshot()

	_cleanup_battle()

func _cleanup_battle() -> void:
	if _battle_scene != null and is_instance_valid(_battle_scene):
		_battle_scene.queue_free()
	_battle_scene = null