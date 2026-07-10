## BattleActor — runtime combat participant during a battle.
## Wraps a StatsResource and tracks live HP, SP, status, and modifiers.
class_name BattleActor
extends RefCounted

# ─── StatModifier ─────────────────────────────────────────────────────────────
## Lightweight modifier applied to a single stat.
## Future: add turns_remaining, display_name when expiration or UI needs them.
class StatModifier:
	extends RefCounted
	var value: int = 0
	var source: StringName = &""

	func _init(p_value: int = 0, p_source: StringName = &"") -> void:
		value = p_value
		source = p_source

# ─── Fields ───────────────────────────────────────────────────────────────────
var actor_id: String = ""
var display_name: String = ""
var team: BattleEnums.Team = BattleEnums.Team.ENEMY
var stats_resource: StatsResource = null

# runtime state
var current_hp: int = 0
var current_sp: int = 0
var status_effects: Array[StatusEffect] = []
var is_guarding: bool = false
var skills: Array[Resource] = []

# temporary stat modifiers, keyed by stat name → array of modifiers
var stat_modifiers: Dictionary = {}

# ─── Static Constructors ──────────────────────────────────────────────────────
static func create_from_character(ch: CharacterResource) -> BattleActor:
	var actor := BattleActor.new()
	actor.actor_id = ch.character_id
	actor.display_name = ch.display_name
	actor.team = BattleEnums.Team.PLAYER
	actor.stats_resource = ch.base_stats
	if ch.base_stats:
		actor.current_hp = ch.base_stats.max_hp
		actor.current_sp = ch.base_stats.max_sp
	actor.skills = ch.starting_skills.duplicate()
	return actor

static func create_from_enemy(en: EnemyResource) -> BattleActor:
	var actor := BattleActor.new()
	actor.actor_id = en.enemy_id
	actor.display_name = en.display_name
	actor.team = BattleEnums.Team.ENEMY
	actor.stats_resource = en.stats
	if en.stats:
		actor.current_hp = en.stats.max_hp
		actor.current_sp = en.stats.max_sp
	actor.skills = en.skills.duplicate()
	return actor

# ─── State Queries ────────────────────────────────────────────────────────────
func is_alive() -> bool:
	return current_hp > 0

func is_player() -> bool:
	return team == BattleEnums.Team.PLAYER

func is_defeated() -> bool:
	return current_hp <= 0

# ─── Stat Getters ─────────────────────────────────────────────────────────────
func get_max_hp() -> int:
	return stats_resource.max_hp if stats_resource else 0

func get_max_sp() -> int:
	return stats_resource.max_sp if stats_resource else 0

func get_attack() -> int:
	return _base_stat("attack") + _sum_mods("attack")

func get_defense() -> int:
	return _base_stat("defense") + _sum_mods("defense")

func get_magic_attack() -> int:
	return _base_stat("magic_attack") + _sum_mods("magic_attack")

func get_magic_defense() -> int:
	return _base_stat("magic_defense") + _sum_mods("magic_defense")

func get_agility() -> int:
	return _base_stat("agility") + _sum_mods("agility")

func get_luck() -> int:
	return _base_stat("luck") + _sum_mods("luck")

# ─── HP / SP Mutations ───────────────────────────────────────────────────────
## Apply damage. Returns actual damage dealt (capped at current_hp).
func take_damage(amount: int) -> int:
	if amount <= 0:
		return 0
	var actual := mini(amount, current_hp)
	current_hp -= actual
	return actual

## Apply healing. Returns amount healed (capped at max_hp - current_hp).
func heal(amount: int) -> int:
	if amount <= 0:
		return 0
	var max_val := get_max_hp()
	var healed := mini(amount, max_val - current_hp)
	current_hp += healed
	return healed

## Consume SP. Returns true if enough SP was available.
func use_sp(amount: int) -> bool:
	if amount <= 0:
		return true
	if current_sp >= amount:
		current_sp -= amount
		return true
	return false

## Restore SP. Returns amount restored.
func restore_sp(amount: int) -> int:
	if amount <= 0:
		return 0
	var max_val := get_max_sp()
	var restored := mini(amount, max_val - current_sp)
	current_sp += restored
	return restored

# ─── Status Effects ───────────────────────────────────────────────────────────
func has_status(effect_type: StatusEffect.Type) -> bool:
	for se in status_effects:
		if se.effect_type == effect_type and se.is_active():
			return true
	return false

func add_status(effect: StatusEffect) -> void:
	# replace existing effect of the same type if present
	remove_status(effect.effect_type)
	status_effects.append(effect)

func remove_status(effect_type: StatusEffect.Type) -> void:
	status_effects = status_effects.filter(
		func(se: StatusEffect) -> bool: return se.effect_type != effect_type
	)

func clear_expired_statuses() -> void:
	status_effects = status_effects.filter(
		func(se: StatusEffect) -> bool: return se.is_active()
	)

# ─── Stat Modifiers ───────────────────────────────────────────────────────────
func add_stat_modifier(stat_name: StringName, mod: StatModifier) -> void:
	if not stat_modifiers.has(stat_name):
		stat_modifiers[stat_name] = []
	stat_modifiers[stat_name].append(mod)

func remove_stat_modifiers_by_source(source: StringName) -> void:
	for key in stat_modifiers.keys():
		var arr: Array = stat_modifiers[key]
		var filtered: Array = []
		for m in arr:
			if m.source != source:
				filtered.append(m)
		if filtered.is_empty():
			stat_modifiers.erase(key)
		else:
			stat_modifiers[key] = filtered

# ─── Private ──────────────────────────────────────────────────────────────────
func _base_stat(stat_name: String) -> int:
	if stats_resource == null:
		return 0
	match stat_name:
		"attack":
			return stats_resource.attack
		"defense":
			return stats_resource.defense
		"magic_attack":
			return stats_resource.magic_attack
		"magic_defense":
			return stats_resource.magic_defense
		"agility":
			return stats_resource.agility
		"luck":
			return stats_resource.luck
		_:
			return 0

func _sum_mods(stat_name: String) -> int:
	var total := 0
	for mod in stat_modifiers.get(stat_name, []):
		total += mod.value
	return total