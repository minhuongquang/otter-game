class_name VNCmdWait
extends VNCommand

## Pauses execution for a specified duration in seconds.

@export var duration: float = 1.0

func _init() -> void:
	command_type = "wait"
	blocking = true

func get_params() -> Dictionary:
	return {
		"duration": duration
	}