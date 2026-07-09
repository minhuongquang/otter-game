## EnemyAI — selects a BattleCommand for an enemy actor.
## Phase 1: always basic attack, random living player target.
class_name EnemyAI
extends RefCounted

# ─── Public API ───────────────────────────────────────────────────────────────
## Choose a command for the given actor. Returns a BattleCommand.
## targets must be an array of living player-side BattleActors.
func choose_command(actor: BattleActor, targets: Array[BattleActor]) -> BattleCommand:
	if targets.is_empty():
		push_error("EnemyAI: no living player targets to attack.")
		return null

	var target := _random_target(targets)
	return BattleCommand.basic_attack(actor, target)

# ─── Private ──────────────────────────────────────────────────────────────────
func _random_target(targets: Array[BattleActor]) -> BattleActor:
	return targets[randi() % targets.size()]