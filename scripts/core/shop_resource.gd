class_name ShopResource
extends Resource

## Data for a shop that sells and buys items.

@export var shop_id: String = ""
@export var shop_name: String = ""
@export var npc_id: String = ""
@export var items: Array[ShopItemEntry] = []
@export var buy_price_modifier: float = 1.0
@export var sell_price_modifier: float = 0.5
@export var restocks: bool = false
