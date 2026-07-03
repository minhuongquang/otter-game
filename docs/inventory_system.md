# Inventory System

> **Purpose**: Define item management, equipment, currency, and crafting systems.  
> **Scope**: InventoryManager, item resources, inventory UI, equipment system.  
> **Status**: Draft — to be refined during implementation.

---

## Overview

The inventory system manages all player items, equipment, and currency. Items are data-driven through ItemResource files.

---

## InventoryManager API

```gdscript
class_name InventoryManager
extends Node

## Item management
func add_item(item_id: String, quantity: int = 1) -> bool
func remove_item(item_id: String, quantity: int = 1) -> bool
func get_item_count(item_id: String) -> int
func has_item(item_id: String) -> bool
func use_item(item_id: String, target_id: String = "") -> bool

## Equipment
func equip_item(character_id: String, item_id: String) -> bool
func unequip_item(character_id: String, slot: String) -> bool
func get_equipped_items(character_id: String) -> Dictionary
func is_item_equipped(item_id: String) -> bool

## Currency
func get_currency() -> int
func add_currency(amount: int) -> void
func remove_currency(amount: int) -> bool

## Query
func get_all_items() -> Array[ItemStack]
func get_items_by_type(item_type: ItemType) -> Array[ItemStack]
func get_item_details(item_id: String) -> ItemResource
```

---

## Item Types

| Type | Description | Stackable | Equippable |
|------|-------------|-----------|------------|
| CONSUMABLE | Usable items (potions, food) | Yes | No |
| EQUIPMENT | Weapons, armor, accessories | No | Yes |
| KEY_ITEM | Story items, quest items | No | No |
| MATERIAL | Crafting materials | Yes | No |
| TREASURE | Sell-only items | Yes | No |

---

## ItemResource

```gdscript
class_name ItemResource
extends Resource

@export var item_id: String
@export var item_name: String
@export var description: String
@export var icon: Texture2D
@export var item_type: ItemType
@export var value: int                    # Buy/sell price
@export var max_stack: int = 99
@export var rarity: Rarity                # COMMON, UNCOMMON, RARE, LEGENDARY
@export var effects: Array[ItemEffect]    # On-use effects
@export var equip_slot: EquipSlot         # If equipment
@export var stat_modifiers: Dictionary    # If equipment
```

---

## Inventory Screen

```
InventoryScreen.tscn (Control)
├── CategoryTabs (TabBar)
│   ├── Consumables
│   ├── Equipment
│   ├── Key Items
│   └── Materials
├── ItemGrid (GridContainer)
│   └── ItemSlot (Button) x N
│       ├── Icon (TextureRect)
│       ├── QuantityLabel (Label)
│       └── RarityBorder (TextureRect)
├── ItemDetail (Panel)
│   ├── ItemIcon (TextureRect)
│   ├── ItemName (Label)
│   ├── ItemDescription (Label)
│   ├── ItemStats (VBoxContainer)
│   └── ActionButtons (HBoxContainer)
│       ├── UseButton (Button)
│       ├── EquipButton (Button)
│       └── DropButton (Button)
└── CloseButton (Button)
```

---

## Equipment Slots

| Slot | Description |
|------|-------------|
| WEAPON | Main hand weapon |
| OFF_HAND | Shield or secondary |
| HEAD | Helmet/headgear |
| BODY | Armor/clothing |
| ACCESSORY_1 | Ring, amulet |
| ACCESSORY_2 | Ring, amulet |

---

## Events

| Event | Data | When |
|-------|------|------|
| item_added | item_id, quantity | Item added to inventory |
| item_removed | item_id, quantity | Item removed |
| item_used | item_id, target | Item consumed |
| item_equipped | character_id, item_id | Equipment changed |
| item_unequipped | character_id, slot | Equipment removed |
| currency_changed | old_value, new_value | Currency updated |

---

## Related

- [architecture.md](architecture.md)
- [game_design.md](game_design.md)
- [database.md](database.md) — Item resources
- [event_system.md](event_system.md) — Inventory events
- [ui_system.md](ui_system.md) — Inventory UI
- [save_system.md](save_system.md) — Saving inventory
