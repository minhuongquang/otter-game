class_name ItemEffect
extends Resource

## Defines one effect of a consumable item.
## Applied when item is used on a target BattleActor.

enum EffectType { HEAL_HP, HEAL_SP, CURE_STATUS }

@export var effect_type: EffectType = EffectType.HEAL_HP
@export var value: int = 0
@export var status_type: StringName = &""