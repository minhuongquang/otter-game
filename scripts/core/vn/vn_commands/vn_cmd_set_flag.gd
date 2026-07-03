class_name VNCmdSetFlag
extends VNCommand

## Sets a story flag to a value. Flags persist across scenes and are saved.

@export var flag_key: String = ""
@export var flag_value: Variant = true

func _init() -> void:
	command_type = "set_flag"
	blocking = false

func get_params() -> Dictionary:
	return {
		"flag_key": flag_key,
		"flag_value": flag_value
	}