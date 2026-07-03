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

enum ItemType { CONSUMABLE, EQUIPMENT, KEY_ITEM, MATERIAL, TREASURE }
enum Rarity { COMMON, UNCOMMON, RARE, LEGENDARY }
