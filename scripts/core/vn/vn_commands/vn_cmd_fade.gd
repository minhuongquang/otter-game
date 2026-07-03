class_name VNCmdFade
extends VNCommand

## Applies a full-screen fade effect.

@export var target_color: String = "black"  # black, white, custom
@export var custom_color: Color = Color.BLACK
@export var duration: float = 1.0

func _init() -> void:
	command_type = "fade"
	blocking = true

func get_params() -> Dictionary:
	return {
		"target_color": target_color,
		"custom_color": custom_color,
		"duration": duration
	}