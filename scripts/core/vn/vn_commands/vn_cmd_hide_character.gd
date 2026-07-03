class_name VNCmdHideCharacter
extends VNCommand

## Hides a character portrait from screen.

@export var character_id: String = ""
@export var animation: String = "fade_out"  # fade_out, slide_left, slide_right, none

func _init() -> void:
	command_type = "hide_character"
	blocking = true

func get_params() -> Dictionary:
	return {
		"character_id": character_id,
		"animation": animation
	}