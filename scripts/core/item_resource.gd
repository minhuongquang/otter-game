class_name ItemResource
extends Resource

## Base class for all item types.

@export var item_id: String = ""
@export var item_name: String = ""
@export var description: String = ""
@export var icon: Texture2D = null
@export var item_type: ItemType = ItemType.CONSUMABLE
@export var value: int = 0
@export var max_stack: int = 99
@export var rarity: Rarity = Rarity.COMMON

## Equipment fields — only used when item_type == EQUIPMENT.
@export var equip_slot: StringName = &""
@export var stat_bonuses: Dictionary = {}

## Consumable effects — only used when item_type == CONSUMABLE.
@export var consumable_effects: Array[ItemEffect] = []

enum ItemType { CONSUMABLE, EQUIPMENT, KEY_ITEM, MATERIAL, TREASURE }
enum Rarity { COMMON, UNCOMMON, RARE, LEGENDARY }
