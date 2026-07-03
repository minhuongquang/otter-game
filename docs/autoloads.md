# Autoloads

> **Purpose**: Document all autoloaded (singleton) scripts, their scope, and lifecycle.  
> **Scope**: Scripts registered in `project.godot` under the Autoload tab.  
> **Status**: Draft — to be updated as autoloads are implemented.

---

## Rules

1. Only global systems that must exist across all scenes.
2. Only systems that cannot be instantiated more than once.
3. Only systems that need to be accessible from anywhere.
4. Keep autoloads minimal — prefer scene-based solutions.
5. Each autoload has a single responsibility.

---

## Updated Autoload List (7 total)

| # | Script | Type | Initialized | Purpose |
|---|--------|------|-------------|---------|
| 1 | `autoload/event_bus.gd` | Node | Boot | Global event dispatch |
| 2 | `autoload/database.gd` | Node | Boot | Resource loading & caching |
| 3 | `autoload/save_manager.gd` | Node | Boot | Save/load game data |
| 4 | `autoload/audio_manager.gd` | Node | Boot | Audio playback control |
| 5 | `autoload/input_manager.gd` | Node | Boot | Input mapping & rebinding |
| 6 | `autoload/ui_manager.gd` | Node | Boot | UI screen stack & HUD |
| 7 | `autoload/scene_manager.gd` | Node | Boot | Scene transitions & loading |

### Load Order

```
EventBus → Database → SaveManager → AudioManager → InputManager → UIManager → SceneManager
```

- Each autoload depends only on those before it in the load order.
- EventBus and Database have zero dependencies.
- SceneManager is last because it depends on UIManager (for transitions) and its own `_ready()` must run after all other systems are available.

---

## Removed Autoloads

The following were in earlier drafts but have been replaced:

- *(None removed. EventBus, SaveManager, AudioManager, InputManager remain. Database, UIManager, SceneManager were added.)*

---

## Prohibited Patterns

- **Do not** create autoloads for features that only appear in specific scenes.
- **Do not** create autoloads for data that can be stored in resources.
- **Do not** add complex game logic inside autoloads — delegate to scene-based managers.
- **Do not** create circular dependencies between autoloads.
- **Do not** call `get_tree().change_scene_to_file()` from scene scripts — always use SceneManager.
- **Do not** add or remove UI nodes directly — always use UIManager.


## 1. EventBus

### Path

### Purpose
Decoupled communication between systems. Any module can emit or listen to events without direct references.

### API Summary
```gdscript
# Emit an event
EventBus.emit_event(event_name: String, data: Dictionary = {})

# Listen to an event
EventBus.listen(event_name: String, callback: Callable)

# Stop listening
EventBus.unlisten(event_name: String, callback: Callable)
```

### Lifecycle
- Created at boot.
- Never removed.
- Exists for entire game session.

### Signals
```gdscript
signal event_emitted(event_name: String, data: Dictionary)
```

### Dependencies
None.

---

## 2. Database

### Path
`res://autoload/database.gd`

### Purpose
Central registry for all game data resources. Provides lazy loading with caching. All managers read game data through Database.

### API Summary
```gdscript
Database.get_item(item_id: String) -> ItemResource
Database.get_enemy(enemy_id: String) -> EnemyResource
Database.get_character(character_id: String) -> CharacterResource
Database.get_quest(quest_id: String) -> QuestResource
Database.get_region(region_id: String) -> RegionResource
Database.get_dialogue(dialogue_id: String) -> DialogueResource
Database.get_skill(skill_id: String) -> SkillResource
Database.get_map(map_id: String) -> MapResource
Database.get_all_in_folder(folder: String) -> Array[Resource]
```

### Lifecycle
- Created at boot (second autoload, after EventBus).
- Exists for entire game session.

### Data Owned
- Resource cache: `Dictionary` mapping `"category/id"` to loaded `Resource`.
- Resources are loaded lazily on first access and cached permanently.

### Loading Strategy
- **Lazy loading**: Resources are loaded only when first requested.
- **Caching**: Loaded resources stay in memory for the session.
- **Error handling**: Missing resources emit `resource_missing` event and return `null`.

### Dependencies
- EventBus (emits `resource_loaded`, `resource_missing`)

---

## 3. SaveManager

### Path
`res://autoload/save_manager.gd`

### Purpose
Handle save file creation, loading, deletion, and versioning.

### API Summary
```gdscript
SaveManager.save(slot: int) -> bool
SaveManager.load(slot: int) -> SaveData
SaveManager.delete(slot: int) -> bool
SaveManager.get_slot_info(slot: int) -> Dictionary
SaveManager.get_save_count() -> int
```

### Lifecycle
- Created at boot.
- Exists for entire game session.

### Data Owned
- Save files on disk.
- Save metadata (timestamps, version, playtime).
- Current save data in memory.

### Dependencies
- EventBus (emits `save_completed`, `load_completed`)

---

## 4. AudioManager

### Path
`res://autoload/audio_manager.gd`

### Purpose
Play BGM, SFX, manage audio buses, crossfade transitions.

### API Summary
```gdscript
AudioManager.play_bgm(resource: AudioStream, fade_in: float = 0.0)
AudioManager.play_sfx(resource: AudioStream, bus: String = "SFX")
AudioManager.stop_bgm(fade_out: float = 0.0)
AudioManager.set_bus_volume(bus: String, volume_db: float)
AudioManager.get_bus_volume(bus: String) -> float
```

### Lifecycle
- Created at boot.
- Exists for entire game session.

### Data Owned
- Current BGM stream.
- Bus volume settings (may be persisted).

### Dependencies
- EventBus (emits `bgm_changed`, `sfx_played`)

---

## 5. InputManager

### Path
`res://autoload/input_manager.gd`

### Purpose
Manage input mappings, controller support, key rebinding.

### API Summary
```gdscript
InputManager.is_action_just_pressed(action: String) -> bool
InputManager.is_action_pressed(action: String) -> bool
InputManager.rebind_action(action: String, event: InputEvent) -> bool
InputManager.reset_to_defaults()
InputManager.get_current_scheme() -> String
```

### Lifecycle
- Created at boot.
- Exists for entire game session.

### Data Owned
- Input map overrides.
- Current control scheme (keyboard/controller).

### Dependencies
- EventBus (emits `input_rebound`, `control_scheme_changed`)

---

## 6. UIManager

### Path
`res://autoload/ui_manager.gd`

### Purpose
Manage UI screen stack, HUD display, overlays, notifications, and transitions. All UI lives in CanvasLayer nodes managed by UIManager.

### API Summary
```gdscript
UIManager.open_screen(screen_id: String, data: Dictionary = {}) -> void
UIManager.close_screen(screen_id: String) -> void
UIManager.is_screen_open(screen_id: String) -> bool
UIManager.show_hud() -> void
UIManager.hide_hud() -> void
UIManager.show_notification(text: String, duration: float = 2.0) -> void
```

### Lifecycle
- Created at boot. UI root added to scene tree immediately.
- Screens and overlays are instantiated/destroyed on demand.

### Data Owned
- UI screen stack (ordered list of open screens).
- Registered screen paths (screen_id → scene_path).
- Current HUD reference.

### Dependencies
- EventBus (emits `screen_opened`, `screen_closed`, `game_paused`, `game_resumed`)

---

## 7. SceneManager

### Path
`res://autoload/scene_manager.gd`

### Purpose
Handle scene transitions, loading screens, fade effects, and scene lifecycle. Centralizes all `change_scene()` calls so that autosave, audio transitions, and UI cleanup happen automatically.

### API Summary
```gdscript
SceneManager.change_scene(scene_path: String, data: Dictionary = {}) -> void
SceneManager.change_scene_with_overlay(scene_path: String, overlay_path: String, data: Dictionary = {}) -> void
SceneManager.reload_current_scene() -> void
SceneManager.get_current_scene_path() -> String
SceneManager.fade_to_black(duration: float) -> Signal
SceneManager.fade_from_black(duration: float) -> Signal
```

### Lifecycle
- Created at boot (last autoload to initialize).
- Exists for entire game session.
- Transitions are queued; concurrent transitions are prevented.

### Data Owned
- Current scene path and reference.
- Transition overlay (ColorRect for fade effects).

### Dependencies
- EventBus (emits `scene_changed`, `scene_loading_started`, `scene_loaded`)
- UIManager (for loading screen and fade overlays)

---

## Implementation Checklist

- [x] Create `autoload/` folder.
- [x] Register 7 autoloads in project.godot (EventBus, Database, SaveManager, AudioManager, InputManager, UIManager, SceneManager).
- [x] Set load order: EventBus → Database → SaveManager → AudioManager → InputManager → UIManager → SceneManager.
- [ ] Implement each autoload script (stubs exist).
- [ ] Document any new autoload in this file.

---

## Prohibited Patterns

- **Do not** create autoloads for features that only appear in specific scenes.
- **Do not** create autoloads for data that can be stored in resources.
- **Do not** add complex game logic inside autoloads — delegate to scene-based managers.
- **Do not** create circular dependencies between autoloads.
- **Do not** call `get_tree().change_scene_to_file()` from scene scripts — always use SceneManager.
- **Do not** add or remove UI nodes directly — always use UIManager.

---

## Related

- [architecture.md](architecture.md) — Autoload vs. scene architecture
- [managers.md](managers.md) — Scene-based managers vs. autoloads
- [event_system.md](event_system.md) — EventBus details
- [save_system.md](save_system.md) — SaveManager implementation
- [audio_system.md](audio_system.md) — AudioManager implementation
- [input_system.md](input_system.md) — InputManager implementation
