## DamageCalculator — stateless utility for damage, healing, hit, and guard calcs.
## All methods are static. No scene or singleton dependencies.
class_name DamageCalculator
extends RefCounted

# ─── DamageCalcResult ─────────────────────────────────────────────────────────
## Typed return value for damage calculation methods.
class DamageCalcResult:
	extends RefCounted

	## Final damage value (after all multipliers, before guard reduction).
	var final_damage: int = 0

	var is_critical: bool = false
	var is_missed: bool = false
	var element_multiplier: float = 1.0
	var was_guarded: bool = false

# ─── Constants ────────────────────────────────────────────────────────────────
const VARIANCE_MIN: float = 0.9
const VARIANCE_MAX: float = 1.1
const CRITICAL_MULTIPLIER: float = 1.5
const GUARD_MULTIPLIER: float = 0.5
const MIN_HIT_CHANCE: float = 0.05
const MAX_HIT_CHANCE: float = 0.95
const LUCK_CRIT_DIVISOR: int = 10

# ─── Element Matchup Table ────────────────────────────────────────────────────
## Multiplier when "row" attacks "col". 2.0 = weak, 0.5 = resist, 0.0 = null.
static var _element_table: Dictionary = {
	BattleEnums.Element.NEUTRAL: {
		BattleEnums.Element.NEUTRAL: 1.0,
		BattleEnums.Element.FIRE: 1.0,
		BattleEnums.Element.WATER: 1.0,
		BattleEnums.Element.WIND: 1.0,
		BattleEnums.Element.EARTH: 1.0,
		BattleEnums.Element.LIGHTNING: 1.0,
		BattleEnums.Element.ICE: 1.0,
		BattleEnums.Element.LIGHT: 1.0,
		BattleEnums.Element.DARK: 1.0,
	},
	BattleEnums.Element.FIRE: {
		BattleEnums.Element.NEUTRAL: 1.0,
		BattleEnums.Element.FIRE: 0.5,
		BattleEnums.Element.WATER: 0.5,
		BattleEnums.Element.WIND: 1.0,
		BattleEnums.Element.EARTH: 1.0,
		BattleEnums.Element.LIGHTNING: 1.0,
		BattleEnums.Element.ICE: 2.0,
		BattleEnums.Element.LIGHT: 1.0,
		BattleEnums.Element.DARK: 1.0,
	},
	BattleEnums.Element.WATER: {
		BattleEnums.Element.NEUTRAL: 1.0,
		BattleEnums.Element.FIRE: 2.0,
		BattleEnums.Element.WATER: 0.5,
		BattleEnums.Element.WIND: 0.5,
		BattleEnums.Element.EARTH: 1.0,
		BattleEnums.Element.LIGHTNING: 0.5,
		BattleEnums.Element.ICE: 1.0,
		BattleEnums.Element.LIGHT: 1.0,
		BattleEnums.Element.DARK: 1.0,
	},
	BattleEnums.Element.WIND: {
		BattleEnums.Element.NEUTRAL: 1.0,
		BattleEnums.Element.FIRE: 1.0,
		BattleEnums.Element.WATER: 1.0,
		BattleEnums.Element.WIND: 0.5,
		BattleEnums.Element.EARTH: 2.0,
		BattleEnums.Element.LIGHTNING: 1.0,
		BattleEnums.Element.ICE: 0.5,
		BattleEnums.Element.LIGHT: 1.0,
		BattleEnums.Element.DARK: 1.0,
	},
	BattleEnums.Element.EARTH: {
		BattleEnums.Element.NEUTRAL: 1.0,
		BattleEnums.Element.FIRE: 1.0,
		BattleEnums.Element.WATER: 1.0,
		BattleEnums.Element.WIND: 0.5,
		BattleEnums.Element.EARTH: 0.5,
		BattleEnums.Element.LIGHTNING: 2.0,
		BattleEnums.Element.ICE: 1.0,
		BattleEnums.Element.LIGHT: 1.0,
		BattleEnums.Element.DARK: 1.0,
	},
	BattleEnums.Element.LIGHTNING: {
		BattleEnums.Element.NEUTRAL: 1.0,
		BattleEnums.Element.FIRE: 1.0,
		BattleEnums.Element.WATER: 2.0,
		BattleEnums.Element.WIND: 1.0,
		BattleEnums.Element.EARTH: 0.5,
		BattleEnums.Element.LIGHTNING: 0.5,
		BattleEnums.Element.ICE: 1.0,
		BattleEnums.Element.LIGHT: 1.0,
		BattleEnums.Element.DARK: 1.0,
	},
	BattleEnums.Element.ICE: {
		BattleEnums.Element.NEUTRAL: 1.0,
		BattleEnums.Element.FIRE: 0.5,
		BattleEnums.Element.WATER: 1.0,
		BattleEnums.Element.WIND: 1.0,
		BattleEnums.Element.EARTH: 1.0,
		BattleEnums.Element.LIGHTNING: 1.0,
		BattleEnums.Element.ICE: 0.5,
		BattleEnums.Element.LIGHT: 1.0,
		BattleEnums.Element.DARK: 1.0,
	},
	BattleEnums.Element.LIGHT: {
		BattleEnums.Element.NEUTRAL: 1.0,
		BattleEnums.Element.FIRE: 1.0,
		BattleEnums.Element.WATER: 1.0,
		BattleEnums.Element.WIND: 1.0,
		BattleEnums.Element.EARTH: 1.0,
		BattleEnums.Element.LIGHTNING: 1.0,
		BattleEnums.Element.ICE: 1.0,
		BattleEnums.Element.LIGHT: 0.5,
		BattleEnums.Element.DARK: 2.0,
	},
	BattleEnums.Element.DARK: {
		BattleEnums.Element.NEUTRAL: 1.0,
		BattleEnums.Element.FIRE: 1.0,
		BattleEnums.Element.WATER: 1.0,
		BattleEnums.Element.WIND: 1.0,
		BattleEnums.Element.EARTH: 1.0,
		BattleEnums.Element.LIGHTNING: 1.0,
		BattleEnums.Element.ICE: 1.0,
		BattleEnums.Element.LIGHT: 2.0,
		BattleEnums.Element.DARK: 0.5,
	},
}

# ─── Damage Calculation ───────────────────────────────────────────────────────
## Calculate physical attack damage against a defender.
static func calculate_physical_damage(
	attacker: BattleActor,
	defender: BattleActor,
	power: int,
	element: BattleEnums.Element = BattleEnums.Element.NEUTRAL,
) -> DamageCalcResult:
	return _calc_damage(attacker, defender, power, element, false)

## Calculate magical attack damage against a defender.
static func calculate_magical_damage(
	attacker: BattleActor,
	defender: BattleActor,
	power: int,
	element: BattleEnums.Element = BattleEnums.Element.NEUTRAL,
) -> DamageCalcResult:
	return _calc_damage(attacker, defender, power, element, true)

## Calculate healing amount (not affected by defense, elements, or variance).
static func calculate_healing(caster: BattleActor, power: int) -> int:
	var base := power * (1.0 + caster.get_magic_attack() * 0.01)
	return maxi(int(base), 1)

# ─── Hit / Critical / Guard ───────────────────────────────────────────────────
## Roll whether the attack misses.
## Hit chance = attacker_agi / (attacker_agi + defender_agi), clamped.
static func roll_miss(attacker_agi: int, defender_agi: int, rng: RandomNumberGenerator = null) -> bool:
	var r := _rng(rng)
	var hit_chance := clampf(
		float(attacker_agi) / float(maxi(attacker_agi + defender_agi, 1)),
		MIN_HIT_CHANCE,
		MAX_HIT_CHANCE,
	)
	return r.randf() > hit_chance

## Roll whether the attack is a critical hit.
## Crit chance = luck / LUCK_CRIT_DIVISOR (10%), min 1%, max 50%.
static func is_critical_hit(luck: int, rng: RandomNumberGenerator = null) -> bool:
	var r := _rng(rng)
	var crit_chance := clampf(float(luck) / float(LUCK_CRIT_DIVISOR) / 100.0, 0.01, 0.50)
	return r.randf() < crit_chance

## Apply guard reduction to base damage.
static func apply_guard(is_guarding: bool, base_damage: int) -> int:
	if is_guarding:
		return maxi(int(float(base_damage) * GUARD_MULTIPLIER), 1)
	return base_damage

# ─── Element Matching ─────────────────────────────────────────────────────────
## Get the damage multiplier for an element attacking a defender's element.
static func get_element_multiplier(
	attack_element: BattleEnums.Element,
	defender_element: BattleEnums.Element,
) -> float:
	var row: Dictionary = _element_table.get(attack_element, {})
	return row.get(defender_element, 1.0)

# ─── Private ──────────────────────────────────────────────────────────────────
static func _calc_damage(
	attacker: BattleActor,
	defender: BattleActor,
	power: int,
	element: BattleEnums.Element,
	is_magical: bool,
) -> DamageCalcResult:
	var result := DamageCalcResult.new()

	var atk: int
	var def: int
	if is_magical:
		atk = attacker.get_magic_attack()
		def = defender.get_magic_defense()
	else:
		atk = attacker.get_attack()
		def = defender.get_defense()

	result.is_missed = roll_miss(attacker.get_agility(), defender.get_agility())
	if result.is_missed:
		return result

	result.is_critical = is_critical_hit(attacker.get_luck())
	result.element_multiplier = get_element_multiplier(element, BattleEnums.Element.NEUTRAL)
	result.was_guarded = defender.is_guarding

	var variance := randf_range(VARIANCE_MIN, VARIANCE_MAX)
	var base := float(power) * (1.0 + float(atk) * 0.01) / (1.0 + float(def) * 0.01)
	var raw := base * variance * result.element_multiplier

	if result.is_critical:
		raw *= CRITICAL_MULTIPLIER

	raw = apply_guard(defender.is_guarding, int(raw))
	result.final_damage = maxi(int(raw), 1)
	return result

static func _rng(rng: RandomNumberGenerator) -> RandomNumberGenerator:
	if rng:
		return rng
	return RandomNumberGenerator.new()