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
static func create_party(character_ids: Array[String], db: Node) -> Array[BattleActor]:
	var result: Array[BattleActor] = []
	for id in character_ids:
		var res: Resource = db.get_character(id)
		if res is CharacterResource:
			result.append(create_actor_from_character(res as CharacterResource))
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