class_name VNCmdUnlockRegion
extends VNCommand

## Unlocks a region on the world map.

@export var region_id: String = ""

func _init() -> void:
	command_type = "unlock_region"
	blocking = false

func get_params() -> Dictionary:
	return {
		"region_id": region_id
	}