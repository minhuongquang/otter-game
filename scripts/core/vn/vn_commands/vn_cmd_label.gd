class_name VNCmdLabel
extends VNCommand

## Internal marker for branch/choice targets. Not displayed to the player.
## Used during compilation to resolve JUMP/LABEL references into command indexes.

@export var label_name: String = ""

func _init() -> void:
	command_type = "label"
	blocking = false

func get_params() -> Dictionary:
	return {
		"label_name": label_name
	}