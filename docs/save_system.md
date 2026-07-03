# Save System

> **Purpose**: Define save/load architecture, data format, versioning, and cloud save support.  
> **Scope**: SaveManager, save data structure, serialization.  
> **Status**: Draft — to be refined during implementation.

---

## Overview

The save system handles saving and loading game state. Save data is versioned for forward compatibility. Autosave and manual saves are supported.

---

## SaveManager API

```gdscript
class_name SaveManager
extends Node

## Save operations
func save_game(slot: int) -> bool
func load_game(slot: int) -> bool
func delete_save(slot: int) -> bool
func slot_exists(slot: int) -> bool

## Slot info
func get_slot_info(slot: int) -> SaveSlotInfo
func get_all_slots() -> Array[SaveSlotInfo]
func get_autosave_info() -> SaveSlotInfo

## Auto-save
func auto_save() -> bool
func set_auto_save_enabled(enabled: bool) -> void

## Quicksave
func quick_save() -> bool
func quick_load() -> bool
```

---

## SaveData Structure

```gdscript
class_name SaveData
extends Resource

## Metadata
@export var save_version: String          # Game version when saved
@export var timestamp: int                # Unix timestamp
@export var playtime: float               # Seconds played
@export var player_name: String

## Story
@export var story_flags: Dictionary       # { flag_name: bool }
@export var current_scene: String         # Active scene path
@export var player_position: Vector2

## Progression
@export var party_members: Array[CharacterData]
@export var inventory: Array[ItemStack]
@export var currency: int
@export var quests: Array[QuestSaveData]
@export var relationships: Dictionary     # { character_id: int }

## Settings
@export var audio_settings: Dictionary
@export var input_bindings: Dictionary
```

---

## Save Slots

| Slot | Type | Overwrite |
|------|------|-----------|
| 0 | Autosave | Auto (on scene change, battle end) |
| 1-5 | Manual | Player confirmation |
| 6-10 | Manual | Player confirmation |
| Quick | Quick save | Manual overwrite |

---

## Save File Location

```
Windows: %APPDATA%/SariaMod/saves/
├── save_0.tres           # Autosave
├── save_1.tres           # Manual slot 1
├── save_2.tres           # Manual slot 2
├── ...
├── save_10.tres          # Manual slot 10
├── quick_save.tres       # Quick save
└── metadata.tres         # Slot metadata
```

---

## Versioning

```gdscript
const SAVE_VERSION: String = "1.0.0"

func migrate_save_data(data: Dictionary, from_version: String) -> Dictionary:
    var version: String = from_version
    while version != SAVE_VERSION:
        match version:
            "1.0.0":
                # No migration needed yet
                pass
            _:
                push_error("Unknown save version: %s" % version)
                break
    return data
```

Each version adds a migration function. Saves are loaded as Dictionaries, migrated, then converted back to typed objects.

---

## Save Triggers

| Event | Trigger |
|-------|---------|
| Scene transition | Autosave |
| Battle victory | Autosave |
| Dialogue completed | Autosave |
| Manual save | Player input |
| Quick save | F5 key |
| Game quit | Autosave (if enabled) |

---

## Save Screen UI

```
SaveScreen.tscn (Control)
├── SlotList (VBoxContainer)
│   ├── SaveSlot (Button) x 10
│   │   ├── SlotNumber (Label)
│   │   ├── SceneName (Label)
│   │   ├── Timestamp (Label)
│   │   ├── Playtime (Label)
│   │   └── EmptyIndicator (Label)
├── ActionButtons (HBoxContainer)
│   ├── SaveButton (Button)
│   ├── LoadButton (Button)
│   └── DeleteButton (Button)
├── ConfirmDialog (ConfirmationDialog)
└── CloseButton (Button)
```

---

## Events

| Event | Data | When |
|-------|------|------|
| game_saved | slot | Save completed |
| game_loaded | slot | Load completed |
| save_failed | slot, error | Save error |
| load_failed | slot, error | Load error |

---

## Related

- [architecture.md](architecture.md)
- [autoloads.md](autoloads.md) — SaveManager
- [event_system.md](event_system.md) — Save events
- [ui_system.md](ui_system.md) — Save screen UI
