class_name VNCmdBranch
extends VNCommand

## Conditional branch: evaluates a condition and jumps to the target label if true.

@export var condition_expression: String = ""  # e.g., "flag_met_saria == true" or "trust_level >= 5"
@export var target_label: String = ""

func _init() -> void:
	command_type = "branch"
	blocking = false

func get_params() -> Dictionary:
	return {
		"condition_expression": condition_expression,
		"target_label": target_label
	}