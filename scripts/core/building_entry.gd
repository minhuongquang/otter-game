class_name BuildingEntry
extends Resource

## Data for a building within a region.
## Each building represents a location the player can enter.

@export var building_id: String = ""
@export var display_name: String = ""
@export var description: String = ""
@export var building_type: BuildingType.Type = BuildingType.Type.TOWN_ENTRY
@export var scene_path: String = ""
@export var required_flag: String = ""
@export var npc_ids: Array[String] = []
@export var shop_id: String = ""
@export var save_point: bool = false
@export var icon: Texture2D = null
@export var position_on_map: Vector2 = Vector2.ZERO
@export var on_enter_events: Array[Dictionary] = []
