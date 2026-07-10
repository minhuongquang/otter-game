## ItemSlot — single item display cell in inventory grid.
## Shows item name and quantity. Emits slot_selected on click.
class_name ItemSlot
extends Button

signal slot_selected(item_id: StringName)

var item_id: StringName = &""
var quantity: int = 0
var display_name: String = "":
	set(v):
		display_name = v
		text = "%s x%d" % [v, quantity]

func _ready() -> void:
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	slot_selected.emit(item_id)