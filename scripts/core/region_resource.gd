class_name RegionResource
extends Resource

## Data for a region on the world map.
## Each region contains buildings, NPCs, shops, and dungeons.

@export var region_id: String = ""
@export var display_name: String = ""
@export var description: String = ""
@export var world_map_position: Vector2 = Vector2.ZERO
@export var icon: Texture2D = null
@export var required_flag: String = ""
@export var required_quest: String = ""
@export var story_flag: String = ""
@export var buildings: Array[BuildingEntry] = []
@export var npc_ids: Array[String] = []
@export var shop_ids: Array[String] = []
@export var dungeon_ids: Array[String] = []
@export var connections: Array[RegionConnection] = []
@export var ambient_bgm: AudioStream = null
@export var ambient_sfx: AudioStream = null