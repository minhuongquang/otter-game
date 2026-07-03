class_name VNCmdChangeExpression
extends VNCommand

## Changes the expression/emotion of a visible character portrait.

@export var character_id: String = ""
@export var emotion: String = "neutral"

func _init() -> void:
	command_type = "change_expression"
	blocking = false

func get_params() -> Dictionary:
	return {
		"character_id": character_id,
		"emotion": emotion
	}