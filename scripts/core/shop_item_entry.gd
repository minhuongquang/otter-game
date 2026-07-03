class_name ShopItemEntry
extends Resource

## Data for a single item entry in a shop's inventory.

@export var item_id: String = ""
@export var price: int = 0
@export var quantity: int = -1  # -1 means unlimited
@export var required_flag: String = ""