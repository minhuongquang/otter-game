class_name VNCmdGiveItem
extends VNCommand

## Gives an item to the player's inventory.

@export var item_id: String = ""
@export var quantity: int = 1

func _init() -> void:
	command_type = "give_item"
	blocking = false

func get_params() -> Dictionary:
	return {
		"item_id": item_id,
		"quantity": quantity
	}