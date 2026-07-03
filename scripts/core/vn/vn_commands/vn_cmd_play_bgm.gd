class_name VNCmdPlayBGM
extends VNCommand

## Plays background music with optional fade-in.

@export var audio_path: String = ""
@export var fade_in: float = 0.0

func _init() -> void:
	command_type = "play_bgm"
	blocking = false

func get_params() -> Dictionary:
	return {
		"audio_path": audio_path,
		"fade_in": fade_in
	}