class_name VNCmdShakeCamera
extends VNCommand

## Applies a camera shake effect.

@export var intensity: float = 0.3
@export var duration: float = 0.5

func _init() -> void:
	command_type = "shake_camera"
	blocking = true

func get_params() -> Dictionary:
	return {
		"intensity": intensity,
		"duration": duration
	}