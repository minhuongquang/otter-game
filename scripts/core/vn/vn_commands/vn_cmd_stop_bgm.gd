class_name VNCmdStopBGM
extends VNCommand

## Stops the currently playing background music with optional fade-out.

@export var fade_out: float = 0.0

func _init() -> void:
	command_type = "stop_bgm"
	blocking = false

func get_params() -> Dictionary:
	return {
		"fade_out": fade_out
	}