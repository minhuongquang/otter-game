## BattleResult — outcome of one executed battle action.
## Contains per-target results for multi-target attacks, healing, status, etc.
class_name BattleResult
extends RefCounted

# ─── TargetResult ─────────────────────────────────────────────────────────────
## Per-target breakdown of an action's effect.
class TargetResult:
	extends RefCounted

	var target: BattleActor

	## Damage dealt to this target (0 if none).
	var damage: int = 0

	## Healing applied to this target (0 if none).
	var healing: int = 0

	## Whether the hit was a critical hit on this target.
	var is_critical: bool = false

	## Whether the action missed this target.
	var is_missed: bool = false

	## Whether this target was defeated by this action.
	var was_defeated: bool = false

	## Status effect applied to this target, if any. Empty string = none applied.
	var status_applied: StringName = &""

# ─── Fields ───────────────────────────────────────────────────────────────────
## The actor who performed the action.
var actor: BattleActor

## The command that was executed.
var command: BattleCommand

## Per-target results in order they were resolved.
var target_results: Array[TargetResult] = []

## Extension point for future mechanics (element interactions, chains, etc.).
var metadata: Dictionary = {}

# ─── Public API ───────────────────────────────────────────────────────────────
func _init(p_actor: BattleActor = null, p_command: BattleCommand = null) -> void:
	actor = p_actor
	command = p_command

## Total damage dealt across all targets.
func total_damage() -> int:
	var total := 0
	for target_result: TargetResult in target_results:
		total += target_result.damage
	return total

## Total healing done across all targets.
func total_healing() -> int:
	var total := 0
	for target_result: TargetResult in target_results:
		total += target_result.healing
	return total

## Whether any target was missed.
func any_missed() -> bool:
	for target_result: TargetResult in target_results:
		if target_result.is_missed:
			return true
	return false

## Whether any hit was critical.
func any_critical() -> bool:
	for target_result: TargetResult in target_results:
		if target_result.is_critical:
			return true
	return false

## Targets that were defeated by this action.
func defeated_targets() -> Array[BattleActor]:
	var result: Array[BattleActor] = []
	for target_result: TargetResult in target_results:
		if target_result.was_defeated:
			result.append(target_result.target)
	return result

## Convenience: add a single-target result.
func add_target_result(
	p_target: BattleActor,
	p_damage: int = 0,
	p_healing: int = 0,
	p_critical: bool = false,
	p_missed: bool = false,
	p_status: StringName = &"",
) -> TargetResult:
	var target_result := TargetResult.new()
	target_result.target = p_target
	target_result.damage = p_damage
	target_result.healing = p_healing
	target_result.is_critical = p_critical
	target_result.is_missed = p_missed
	target_result.was_defeated = p_damage > 0 and not p_target.is_alive()
	target_result.status_applied = p_status
	target_results.append(target_result)
	return target_result
