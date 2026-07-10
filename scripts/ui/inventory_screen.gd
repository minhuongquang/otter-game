## InventoryScreen — full inventory UI controller.
## Reads from InventoryManager (stateless helper), displays PartyState data.
## Opened by UIManager. Closing emits back to game.
class_name InventoryScreen
extends Control

# ─── Signals ──────────────────────────────────────────────────────────────────
signal closed

# ─── @onready ─────────────────────────────────────────────────────────────────
@onready var tab_bar: TabBar = %TabBar
@onready var item_grid: GridContainer = %ItemGrid
@onready var detail_panel: InventoryDetail = %DetailPanel
@onready var gold_label: Label = %GoldLabel
@onready var close_button: Button = %CloseButton
@onready var equip_button: Button = %EquipButton
@onready var unequip_button: Button = %UnequipButton
@onready var use_button: Button = %UseButton

# ─── State ────────────────────────────────────────────────────────────────────
var _inventory: InventoryManager = null
var _current_category: int = ItemResource.ItemType.CONSUMABLE
var _selected_item_id: StringName = &""
var _selected_character_id: String = "hero"

# ─── Lifecycle ────────────────────────────────────────────────────────────────
func _ready() -> void:
	_inventory = InventoryManager.new()
	tab_bar.tab_changed.connect(_on_tab_changed)
	close_button.pressed.connect(_on_close_pressed)
	use_button.pressed.connect(_on_use_pressed)
	equip_button.pressed.connect(_on_equip_pressed)
	unequip_button.pressed.connect(_on_unequip_pressed)
	_refresh()

# ─── Refresh ──────────────────────────────────────────────────────────────────
func _refresh() -> void:
	gold_label.text = "Gold: %d" % PartyState.gold
	_build_grid()
	_update_detail()
	_update_buttons()

func _build_grid() -> void:
	for child in item_grid.get_children():
		child.queue_free()

	var items := _inventory.get_items_by_type(_current_category)
	for item in items:
		var slot := _create_slot(item["item_id"], item["quantity"])
		item_grid.add_child(slot)

func _create_slot(item_id: StringName, quantity: int) -> Control:
	var slot := ItemSlot.new()
	slot.item_id = item_id
	slot.quantity = quantity
	var item_res := _inventory.get_item_resource(item_id)
	if item_res != null:
		slot.display_name = item_res.item_name
	slot.slot_selected.connect(_on_slot_selected)
	return slot

func _update_detail() -> void:
	if _selected_item_id == &"":
		detail_panel.clear()
		return
	var item_res := _inventory.get_item_resource(_selected_item_id)
	if item_res == null:
		detail_panel.clear()
		return
	detail_panel.show_item(item_res)

func _update_buttons() -> void:
	if _selected_item_id == &"":
		use_button.disabled = true
		equip_button.disabled = true
		unequip_button.disabled = true
		return

	var item_res := _inventory.get_item_resource(_selected_item_id)
	if item_res == null:
		use_button.disabled = true
		equip_button.disabled = true
		unequip_button.disabled = true
		return

	match item_res.item_type:
		ItemResource.ItemType.CONSUMABLE:
			use_button.disabled = false
			equip_button.disabled = true
			unequip_button.disabled = true
		ItemResource.ItemType.EQUIPMENT:
			use_button.disabled = true
			equip_button.disabled = false
			var slot: StringName = item_res.equip_slot
			var currently_equipped: StringName = PartyState.get_equipped(_selected_character_id, slot)
			unequip_button.disabled = (currently_equipped == &"")
		_:
			use_button.disabled = true
			equip_button.disabled = true
			unequip_button.disabled = true

# ─── Signal Handlers ──────────────────────────────────────────────────────────
func _on_tab_changed(tab: int) -> void:
	match tab:
		0:
			_current_category = ItemResource.ItemType.CONSUMABLE
		1:
			_current_category = ItemResource.ItemType.EQUIPMENT
		2:
			_current_category = ItemResource.ItemType.KEY_ITEM
	_selected_item_id = &""
	_refresh()

func _on_slot_selected(item_id: StringName) -> void:
	_selected_item_id = item_id
	_update_detail()
	_update_buttons()

func _on_use_pressed() -> void:
	if _selected_item_id == &"":
		return
	var item_res := _inventory.get_item_resource(_selected_item_id)
	if item_res == null:
		return
	if item_res.item_type != ItemResource.ItemType.CONSUMABLE:
		return
	_inventory.use_item_map(_selected_item_id)
	_refresh()

func _on_equip_pressed() -> void:
	if _selected_item_id == &"":
		return
	var item_res := _inventory.get_item_resource(_selected_item_id)
	if item_res == null:
		return
	if item_res.item_type != ItemResource.ItemType.EQUIPMENT:
		return
	_inventory.equip_item(_selected_character_id, _selected_item_id)
	_refresh()

func _on_unequip_pressed() -> void:
	if _selected_item_id == &"":
		return
	var item_res := _inventory.get_item_resource(_selected_item_id)
	if item_res == null:
		return
	if item_res.item_type != ItemResource.ItemType.EQUIPMENT:
		return
	PartyState.unequip_item(_selected_character_id, item_res.equip_slot)
	_refresh()

func _on_close_pressed() -> void:
	closed.emit()
	queue_free()