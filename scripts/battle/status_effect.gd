## StatusEffect — a single status condition, buff, or debuff on a BattleActor.
class_name StatusEffect
extends RefCounted

# ─── Types ────────────────────────────────────────────────────────────────────
enum Type {
	POISON,
	SLEEP,
	PARALYSIS,
	BURN,
	FREEZE,
	BLIND,
	ATTACK_UP,
	ATTACK_DOWN,
	DEFENSE_UP,
	DEFENSE_DOWN,
	AGILITY_UP,
	AGILITY_DOWN,
	REGEN,
	SHIELD,
}

# ─── Fields ───────────────────────────────────────────────────────────────────
var effect_type: Type
var turns_remaining: int = 0
var power: int = 0
var is_buff: bool = false

# ─── Public API ───────────────────────────────────────────────────────────────
func _init(p_type: Type, p_turns: int = 0, p_power: int = 0) -> void:
	effect_type = p_type
	turns_remaining = p_turns
	power = p_power
	is_buff = _is_buff_type(p_type)

## Whether this effect is still active (has turns remaining).
func is_active() -> bool:
	return turns_remaining > 0

## Decrement the turn counter by one.
func tick() -> void:
	if turns_remaining > 0:
		turns_remaining -= 1

# ─── Private ──────────────────────────────────────────────────────────────────
func _is_buff_type(p_type: Type) -> bool:
	match p_type:
		Type.ATTACK_UP, Type.DEFENSE_UP, Type.AGILITY_UP, Type.REGEN, Type.SHIELD:
			return true
		_:
			return false