class_name VNCmdBackground
extends VNCommand

## Changes the VN background image with an optional transition.

@export var texture_path: String = ""
@export var transition: String = "fade"  # fade, dissolve, none
@export var duration: float = 1.0

func _init() -> void:
	command_type = "background"
	blocking = true

func get_params() -> Dictionary:
	return {
		"texture_path": texture_path,
		"transition": transition,
		"duration": duration
	}