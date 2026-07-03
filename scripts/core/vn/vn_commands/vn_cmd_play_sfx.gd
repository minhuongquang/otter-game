class_name VNCmdPlaySFX
extends VNCommand

## Plays a sound effect.

@export var audio_path: String = ""
@export var volume: float = 0.0  # dB adjustment

func _init() -> void:
	command_type = "play_sfx"
	blocking = false

func get_params() -> Dictionary:
	return {
		"audio_path": audio_path,
		"volume": volume
	}