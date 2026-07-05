## BattleCommand — represents one pending battle action.
## No UI. No execution logic. Created by input handlers, executed by BattleManager.
class_name BattleCommand
extends RefCounted

# ─── Fields ───────────────────────────────────────────────────────────────────
var actor: BattleActor
var targets: Array[BattleActor]

var command_type: BattleEnums.CommandType = BattleEnums.CommandType.ATTACK

## Skill resource when command_type == SKILL, otherwise null.
var skill: SkillResource = null

## Item ID placeholder. Resolved by inventory system when available (future M7).
var item_id: StringName = &""

## Priority for turn ordering. Higher values resolve earlier.
var priority: int = 0

## Extension point for future mechanics (status modifiers, combo flags, etc.).
var metadata: Dictionary = {}

# ─── Public API ───────────────────────────────────────────────────────────────
func _init(
	p_actor: BattleActor = null,
	p_targets: Array[BattleActor] = [],
	p_command_type: BattleEnums.CommandType = BattleEnums.CommandType.ATTACK,
	p_skill: SkillResource = null,
) -> void:
	actor = p_actor
	targets = p_targets
	command_type = p_command_type
	skill = p_skill

## Convenience: create a basic attack command.
static func basic_attack(p_actor: BattleActor, p_target: BattleActor) -> BattleCommand:
	return BattleCommand.new(p_actor, [p_target], BattleEnums.CommandType.ATTACK)

## Convenience: create a skill command.
static func use_skill(p_actor: BattleActor, p_targets: Array[BattleActor], p_skill: SkillResource) -> BattleCommand:
	var cmd := BattleCommand.new(p_actor, p_targets, BattleEnums.CommandType.SKILL, p_skill)
	return cmd

## Convenience: create a guard command.
static func guard(p_actor: BattleActor) -> BattleCommand:
	return BattleCommand.new(p_actor, [], BattleEnums.CommandType.GUARD)

## Convenience: create a flee command.
static func flee(p_actor: BattleActor) -> BattleCommand:
	return BattleCommand.new(p_actor, [], BattleEnums.CommandType.FLEE)