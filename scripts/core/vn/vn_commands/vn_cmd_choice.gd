class_name VNCmdChoice
extends VNCommand

## Presents a set of choices to the player. Each choice has text, optional effects, and a target label.

@export var choices: Array[VNChoiceData] = []

func _init() -> void:
	command_type = "choice"
	blocking = true

func get_params() -> Dictionary:
	return {
		"choices": choices
	}