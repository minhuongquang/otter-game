## BattleFactory — stateless factory converting Resources → runtime BattleActor.
## All methods are static. No scene or singleton dependencies.
class_name BattleFactory
extends RefCounted

# ─── Public API ───────────────────────────────────────────────────────────────
## Create a single BattleActor from a CharacterResource.
static func create_actor_from_character(ch: CharacterResource) -> BattleActor:
	return BattleActor.create_from_character(ch)

## Create a single BattleActor from an EnemyResource.
static func create_actor_from_enemy(en: EnemyResource) -> BattleActor:
	return BattleActor.create_from_enemy(en)

## Create party of BattleActors from character IDs using Database autoload.
## Applies equipment bonuses from PartyState as base StatModifiers.
static func create_party(character_ids: Array[String], db: Node) -> Array[BattleActor]:
	var result: Array[BattleActor] = []
	for id in character_ids:
		var res: Resource = db.get_character(id)
		if res is CharacterResource:
			var actor := create_actor_from_character(res as CharacterResource)
			_apply_equipment_bonuses(actor, id, db)
			result.append(actor)
		else:
			push_error("BattleFactory: character not found — %s" % id)
	return result

## Create enemies from enemy IDs using Database autoload.
static func create_enemies(enemy_ids: Array[String], db: Node) -> Array[BattleActor]:
	var result: Array[BattleActor] = []
	for id in enemy_ids:
		var res: Resource = db.get_enemy(id)
		if res is EnemyResource:
			result.append(create_actor_from_enemy(res as EnemyResource))
		else:
			push_error("BattleFactory: enemy not found — %s" % id)
	return result

# ─── Private ──────────────────────────────────────────────────────────────────
## Apply equipment stat bonuses from PartyState to the actor as StatModifiers.
static func _apply_equipment_bonuses(actor: BattleActor, character_id: String, _db: Node) -> void:
	var party_state: PartyState
	for s in Engine.get_singleton_list():
		if str(s) == "PartyState":
			party_state = Engine.get_singleton(s)
			break
	if party_state == null:
		return
	var bonuses: Dictionary = party_state.get_equipment_bonuses(character_id)
	for stat_name: String in bonuses:
		var mod := BattleActor.StatModifier.new(int(bonuses[stat_name]), &"base")
		actor.add_stat_modifier(StringName(stat_name), mod)
