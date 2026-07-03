class_name VNCmdStartCutscene
extends VNCommand

## Triggers a cinematic cutscene sequence.

@export var cutscene_id: String = ""

func _init() -> void:
	command_type = "start_cutscene"
	blocking = true

func get_params() -> Dictionary:
	return {
		"cutscene_id": cutscene_id
	}