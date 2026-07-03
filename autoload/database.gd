extends Node

## Central registry for all game data resources.
## Provides lazy loading with caching.
## All managers read game data through Database.
##
## Usage:
##   var potion: ItemResource = Database.get_item("potion_small")
##   var goblin: EnemyResource = Database.get_enemy("goblin")

# === Constants ===
const BASE_PATH: String = "res://database/"

# === Private ===
var _cache: Dictionary = {}  # resource_id -> Resource

# === Public Methods ===

## Get an item resource by ID. Loads on first access.
func get_item(item_id: String) -> Resource:
	return _load_resource(item_id, "items", "ItemResource")

## Get an enemy resource by ID.
func get_enemy(enemy_id: String) -> Resource:
	return _load_resource(enemy_id, "enemies", "EnemyResource")

## Get a character resource by ID.
func get_character(character_id: String) -> Resource:
	return _load_resource(character_id, "characters", "CharacterResource")

## Get a quest resource by ID.
func get_quest(quest_id: String) -> Resource:
	return _load_resource(quest_id, "quests", "QuestResource")

## Get a region resource by ID.
func get_region(region_id: String) -> Resource:
	return _load_resource(region_id, "regions", "RegionResource")

## Get a dialogue resource by ID.
func get_dialogue(dialogue_id: String) -> Resource:
	return _load_resource(dialogue_id, "dialogue", "DialogueResource")

## Get a skill resource by ID.
func get_skill(skill_id: String) -> Resource:
	return _load_resource(skill_id, "skills", "SkillResource")

## Get a map resource by ID.
func get_map(map_id: String) -> Resource:
	return _load_resource(map_id, "maps", "MapResource")

## Get a shop resource by ID.
func get_shop(shop_id: String) -> Resource:
	return _load_resource(shop_id, "shops", "ShopResource")

## Get a building entry by ID (loads from building subfolder).
func get_building(building_id: String) -> Resource:
	return _load_resource(building_id, "buildings", "BuildingEntry")

## Get all region resources.
func get_all_regions() -> Array[Resource]:
	return get_all_in_folder("regions")

## Get all shop resources.
func get_all_shops() -> Array[Resource]:
	return get_all_in_folder("shops")

## Get all items of a given type from a folder.
func get_all_in_folder(folder: String) -> Array[Resource]:
	var path: String = BASE_PATH + folder + "/"
	var dir: DirAccess = DirAccess.open(path)
	var results: Array[Resource] = []
	
	if dir == null:
		push_error("Database: Cannot open folder: %s" % path)
		return results
	
	dir.list_dir_begin()
	var file_name: String = dir.get_next()
	while file_name != "":
		if file_name.ends_with(".tres") or file_name.ends_with(".res"):
			var resource: Resource = load(path + file_name)
			if resource:
				results.append(resource)
		file_name = dir.get_next()
	dir.list_dir_end()
	return results

# === Private Methods ===

## Lazy-load a resource by category and ID.
func _load_resource(resource_id: String, category: String, expected_type: String) -> Resource:
	var cache_key: String = category + "/" + resource_id
	
	if _cache.has(cache_key):
		return _cache[cache_key]
	
	var path: String = BASE_PATH + category + "/" + resource_id + ".tres"
	var resource: Resource = load(path)
	
	if resource == null:
		push_error("Database: %s not found: %s at %s" % [expected_type, resource_id, path])
		EventBus.emit_event("resource_missing", {"id": resource_id, "type": expected_type, "path": path})
		return null
	
	_cache[cache_key] = resource
	EventBus.emit_event("resource_loaded", {"id": resource_id, "type": expected_type})
	return resource
