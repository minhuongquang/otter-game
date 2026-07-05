class_name ExplorationExit
extends Area2D

## Placed in exploration maps to allow the player to exit back to a RegionHub.
##
## Reads [code]region_id[/code] from SceneManager pending data on scene load,
## and uses it when the player enters the area to transition back to the
## correct RegionHub.
##
## Usage: Add as a child of the exploration scene, connect to nothing.

# === Private ===
var _region_id: String = ""

# === Built-in ===
func _ready() -> void:
	var data: Dictionary = SceneManager.get_pending_data()
	if data.has("region_id") and not data["region_id"].is_empty():
		_region_id = data["region_id"]
	
	if _region_id.is_empty():
		push_warning("ExplorationExit: No region_id in pending data")
	
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		SceneManager.change_scene("res://scenes/world/region_hub.tscn", {
			"region_id": _region_id
		})