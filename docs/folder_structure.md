# Folder Structure

> **Purpose**: Define the physical folder layout and rules for where files belong.  
> **Scope**: All assets, scripts, scenes, and data files.  
> **Status**: Draft — to be updated as new categories emerge.

---

## Top-Level Structure

```
SariaMod/
├── .clinerules/          # AI assistant configuration
├── assets/               # Raw and imported assets
├── autoload/             # Singleton scripts (autoloads)
├── database/             # Data resources (items, enemies, etc.)
├── docs/                 # Project documentation
├── scenes/               # All scene files
├── scripts/              # All script files
├── tests/                # Test scenes and scripts
├── addons/               # Godot plugins
├── project.godot         # Godot project configuration
└── .gitignore            # Git ignore rules
```

---

## Assets

```
assets/
├── art/
│   ├── backgrounds/      # VN backgrounds, battle backs
│   ├── characters/       # Character sprites, portraits
│   ├── enemies/          # Enemy sprites
│   ├── environment/      # Tilesets, terrain, props
│   ├── effects/          # VFX, particles, animations
│   ├── items/            # Item icons
│   ├── ui/               # UI elements, buttons, frames
│   └── world/            # World map assets
├── audio/
│   ├── bgm/              # Background music
│   ├── sfx/              # Sound effects
│   └── voice/            # Voice clips (future)
├── fonts/                # Font files
├── shaders/              # Custom shader files
└── vfx/                  # Visual effect resources
```

---

## Autoload

```
autoload/
├── event_bus.gd
├── database.gd
├── save_manager.gd
├── audio_manager.gd
├── input_manager.gd
├── ui_manager.gd
└── scene_manager.gd
```

Only global singletons that must exist for the entire game lifetime.

**Total: 7 autoloads** (EventBus, Database, SaveManager, AudioManager, InputManager, UIManager, SceneManager)

---

## Database

```
database/
├── characters/           # Character data resources
├── dialogue/             # Dialogue resources
├── enemies/              # Enemy data resources
├── items/                # Item data resources
├── maps/                 # Map / room data
├── quests/               # Quest data resources
├── regions/              # Region definitions
└── skills/               # Skill data resources
```

Every folder contains `.tres` or `.res` Godot resource files.

---

## Scenes

```
scenes/
├── battle/
│   ├── battle_scene.tscn
│   ├── enemy_panel.tscn
│   └── party_panel.tscn
├── characters/
│   ├── npc.tscn
│   ├── player.tscn
│   └── portrait.tscn
├── exploration/
│   ├── exploration_scene.tscn
│   ├── interactable.tscn
│   └── portal.tscn
├── ui/
│   ├── dialogue_box.tscn
│   ├── hud.tscn
│   ├── inventory_screen.tscn
│   ├── main_menu.tscn
│   ├── pause_menu.tscn
│   ├── quest_log.tscn
│   └── save_screen.tscn
├── world/
│   ├── world_map.tscn
│   ├── town.tscn
│   ├── room.tscn
│   ├── visual_novel.tscn
│   └── location_icon.tscn
```

---

## Scripts

```
scripts/
├── battle/
│   ├── battle_manager.gd
│   ├── enemy_ai.gd
│   └── damage_calculator.gd
├── components/
│   ├── health_component.gd
│   ├── movement_component.gd
│   └── interactable_component.gd
├── core/
│   ├── event_bus.gd
│   ├── database.gd
│   ├── item_resource.gd
│   ├── dialogue_resource.gd
│   ├── enemy_resource.gd
│   ├── quest_resource.gd
│   ├── skill_resource.gd
│   ├── character_resource.gd
│   ├── region_resource.gd
│   ├── map_resource.gd
│   └── stats_resource.gd
├── managers/
│   ├── dialogue_manager.gd
│   ├── exploration_manager.gd
│   ├── inventory_manager.gd
│   └── quest_manager.gd
├── ui/
│   ├── dialogue_box.gd
│   ├── hud.gd
│   ├── inventory_screen.gd
│   ├── main_menu.gd
│   ├── pause_menu.gd
│   ├── quest_log.gd
│   └── save_screen.gd
├── world/
│   ├── npc.gd
│   ├── player_controller.gd
│   ├── portal.gd
│   ├── world_map.gd
│   └── visual_novel.gd
└── utilities/
    ├── math_utils.gd
    ├── string_utils.gd
    └── random_utils.gd
```

---

## Rules

### What Goes Where

| File Type | Folder | Why |
|-----------|--------|-----|
| Scene file (.tscn) | `scenes/` | All scenes in one tree |
| Script (.gd) | `scripts/` | Mirrors scene structure |
| Resource (.tres/.res) | `database/` | Data is separate from code |
| Art asset | `assets/art/` | Organized by type, then feature |
| Audio asset | `assets/audio/` | Organized by type |
| Singleton script | `autoload/` | Must be registered in project.godot |
| Plugin | `addons/` | Third-party or reusable internal |
| Test | `tests/` | Mirrors script structure |

### Prohibited

- Do not place game data inside scripts (hardcoding).
- Do not place scripts inside asset folders.
- Do not create new top-level folders without updating this document.
- Do not mix source assets with generated assets.
- Do not store documentation inside source folders.

### Naming

- Folders: `snake_case`
- Scene files: `snake_case.tscn`
- Script files: `snake_case.gd`
- Resource files: `snake_case.tres` (or `.res`)

---

## Future Additions

| Feature | New Folders Needed |
|---------|-------------------|
| Crafting System | `database/recipes/` |
| Achievements | `database/achievements/` |
| Shop System | `database/shops/` |
| Localization | `assets/strings/` |
| Modding | `mods/` (top-level) |
| DLC | `dlc/` (top-level) |

---

## Related

- [architecture.md](architecture.md) — Module architecture
- [scene_architecture.md](scene_architecture.md) — Scene composition
- [database.md](database.md) — Data resource organization
- [resource_pipeline.md](resource_pipeline.md) — Asset pipeline
