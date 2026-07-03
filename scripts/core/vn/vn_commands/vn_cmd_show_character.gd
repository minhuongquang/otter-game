class_name VNCmdShowCharacter
extends VNCommand

## Shows a character portrait on screen at a specified position.

@export var character_id: String = ""
@export var position: String = "center"  # left, center, right, far_left, far_right
@export var animation: String = "fade_in"  # fade_in, slide_left, slide_right, none

func _init() -> void:
	command_type = "show_character"
	blocking = true

func get_params() -> Dictionary:
	return {
		"character_id": character_id,
		"position": position,
		"animation": animation
	}