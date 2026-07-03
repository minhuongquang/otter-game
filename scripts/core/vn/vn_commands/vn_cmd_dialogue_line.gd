class_name VNCmdDialogueLine
extends VNCommand

## Displays a line of dialogue text with speaker information.

@export var speaker_id: String = ""
@export var display_name: String = ""
@export var emotion: String = "neutral"
@export var dialogue_text: String = ""
@export var voice_line: AudioStream = null

func _init() -> void:
	command_type = "dialogue_line"
	blocking = true

func get_params() -> Dictionary:
	return {
		"speaker_id": speaker_id,
		"display_name": display_name,
		"emotion": emotion,
		"dialogue_text": dialogue_text,
		"voice_line": voice_line
	}