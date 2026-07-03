class_name VNCmdSetVariable
extends VNCommand

## Sets a VN-local variable with an operator (assign, add, subtract, multiply, divide).

@export var var_key: String = ""
@export var operator: String = "assign"  # assign, add, subtract, multiply, divide
@export var var_value: Variant = 0

func _init() -> void:
	command_type = "set_variable"
	blocking = false

func get_params() -> Dictionary:
	return {
		"var_key": var_key,
		"operator": operator,
		"var_value": var_value
	}