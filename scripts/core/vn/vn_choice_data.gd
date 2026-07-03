class_name VNChoiceData
extends Resource

## Data for a single choice option in a VN choice command.

@export var choice_text: String = ""
@export var target_label: String = ""
@export var effects: Array[Dictionary] = []  # List of { "type": String, "key": String, "value": Variant }
@export var condition_expression: String = ""  # Optional: only show this choice if condition is met