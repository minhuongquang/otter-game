class_name VNCmdStartBattle
extends VNCommand

## Triggers a battle encounter.

@export var enemy_group_id: String = ""

func _init() -> void:
	command_type = "start_battle"
	blocking = true

func get_params() -> Dictionary:
	return {
		"enemy_group_id": enemy_group_id
	}