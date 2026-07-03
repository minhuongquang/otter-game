class_name VNCmdAnimation
extends VNCommand

## Triggers an animation on a target element (character portrait, background, etc.).

@export var target: String = ""  # character_id, "background", "screen"
@export var animation_id: String = ""  # "wave", "blush", "flash", "shake", "bounce"
@export var params: Dictionary = {}  # Extra parameters like speed, repeat, etc.

func _init() -> void:
	command_type = "animation"
	blocking = true

func get_params() -> Dictionary:
	return {
		"target": target,
		"animation_id": animation_id,
		"params": params
	}