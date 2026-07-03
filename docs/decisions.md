# Architecture Decision Records

> **Purpose**: Document significant architectural decisions, their rationale, and alternatives considered.  
> **Type**: Living document — append new decisions as they are made.  
> **Last Updated**: 2026-06-28

---

## Format

Each decision follows this template:

```
## ADR-NNN: Title

**Date**: YYYY-MM-DD
**Status**: [Proposed | Accepted | Deprecated | Superseded]

### Context
Why is this decision needed? What problem does it solve?

### Decision
What was decided? What is the new state?

### Rationale
Why was this option chosen over alternatives?

### Consequences
What trade-offs, risks, or follow-up work are involved?

### Alternatives Considered
- Alternative A: Why not chosen.
- Alternative B: Why not chosen.
```

---

## ADR-001: EventBus Pattern

**Date**: 2026-06-28
**Status**: Accepted

### Context
Gameplay modules need to communicate without direct coupling. Dialogue needs to trigger quests. Battles need to notify inventory of rewards.

### Decision
Use a centralized EventBus (autoload) with String-based event names and Dictionary data payloads.

### Rationale
- Decouples all modules completely.
- New systems can listen without modifying emitters.
- Simple to implement and debug.
- Dictionary payloads are flexible and extendable.

### Consequences
- Events are loosely typed (strings + dictionaries).
- High-frequency events need batching (not per-frame).
- All nodes must unlisten in _exit_tree() to avoid errors.

### Alternatives Considered
- **Direct signal connections**: Creates coupling. Emitter must know listener.
- **Typed event classes**: More type-safe but more boilerplate. Can be added later for critical events.
- **Message queue pattern**: Over-engineered for this scale.

---

## ADR-002: Resource-Based Data

**Date**: 2026-06-28
**Status**: Accepted

### Context
All game content (items, enemies, quests, dialogue) needs to be data-driven and editable without code changes.

### Decision
Store all game content as Godot Resource files (.tres) in a `database/` folder hierarchy.

### Rationale
- Native Godot format with Inspector editing.
- Type-safe (fields are typed).
- Inheritable (ItemResource -> ConsumableItemResource).
- Hot-reloadable (changes apply without restart).
- Serializable (saves can reference resources by ID).

### Consequences
- Requires a Database autoload for resource lookup.
- Large number of .tres files needs organization.
- Text-based .tres files work with Git diffs.

### Alternatives Considered
- **JSON/CSV files**: Not type-safe, need custom importers, no Inspector support.
- **Hardcoded data in scripts**: Violates data-driven principle, requires code changes for content.
- **SQLite database**: Over-engineered, not native to Godot.

---

## ADR-003: Autoload vs. Scene-Based Managers

**Date**: 2026-06-28
**Status**: Accepted

### Context
Managers can be autoloaded (global singletons) or scene-based (instantiated when needed).

### Decision
Core systems (EventBus, SaveManager, AudioManager, InputManager) are autoloads. Gameplay managers (Dialogue, Battle, Exploration, Quest, Inventory) are scene-based.

### Rationale
- Core systems must exist across all scenes and be globally accessible.
- Gameplay managers only exist in relevant scenes (BattleManager only in battle).
- Limits the number of autoloads to 4 (keeps startup fast).
- Scene-based managers are easier to test in isolation.

### Consequences
- Scene managers communicate through EventBus, not direct references.
- Scene managers must be passed data through exports or events.

### Alternatives Considered
- **All managers as autoloads**: Startup bloat, unused managers in memory.
- **All managers as scene-based**: No global access for core systems.

---

## ADR-004: No Circular Dependencies

**Date**: 2026-06-28
**Status**: Accepted

### Context
Modules may be tempted to reference each other directly for convenience.

### Decision
All module-to-module communication goes through EventBus. No gameplay module references another gameplay module directly.

### Rationale
- Prevents circular dependencies.
- Makes modules independently testable.
- New features can react to events without modifying existing code.

### Consequences
- Events must be well-documented so modules know what to listen for.
- Some operations require multiple event emissions where a direct call would be simpler.

---

## ADR-005: Input Context System

**Date**: 2026-06-28
**Status**: Accepted

### Context
Different gameplay modes (exploration, battle, VN, menu) require different input mappings. A single global input map causes conflicts.

### Decision
Implement an input context system in InputManager. Each gameplay mode pushes its context. Only active context actions are processed.

### Rationale
- No conflict between modes (Esc in menu vs. Esc in battle).
- Contexts can be stacked (menu on top of exploration).
- Rebinding works per-action, not per-context.

### Consequences
- All game code must use context-aware input checks.
- Context transitions must be managed carefully.

---

---

## ADR-006: SceneManager as Autoload

**Date**: 2026-06-29
**Status**: Accepted

### Context
Scene transitions are a global concern. Multiple documents referenced a `SceneManager` but it was never defined as an autoload or scene manager. Without it, each scene manages its own transitions, leading to duplicated fade effects, loading screens, and autosave triggers.

### Decision
Create `SceneManager` as the 7th autoload (loaded last). All scene transitions use `SceneManager.change_scene()`. SceneManager emits `scene_changed` events that other autoloads (SaveManager, AudioManager, UIManager) listen to.

### Rationale
- Scene transitions must work from any scene and any autoload.
- Loading screen management is a global concern.
- Centralizing fades, autosave, and BGM transitions prevents code duplication.
- A single `scene_changed` event simplifies cross-system coordination.

### Consequences
- All existing `get_tree().change_scene_to_file()` calls must be replaced.
- SceneManager must be loaded last in autoload order.
- Transitions are queued; concurrent transitions are prevented.

### Alternatives Considered
- **Per-scene transition code**: Duplicated logic, hard to maintain.
- **Signals on root Window**: Less explicit, harder to debug.

---

## ADR-007: Lazy Resource Loading with Cache

**Date**: 2026-06-29
**Status**: Accepted

### Context
The Database system needs to load game data resources. Preloading all at boot is slow and memory-intensive. Lazy-loading on first access balances boot time with runtime performance.

### Decision
Implement lazy loading with a permanent session cache in the Database autoload. On first request, load the resource from disk. Cache it by `"category/id"` key. Missing resources emit an error and return `null`.

### Rationale
- Boot time stays fast regardless of content volume.
- Memory is used only for resources that are actually accessed.
- Cache is simple (Dictionary) and predictable.
- Resources are immutable — no need for cache invalidation.

### Consequences
- First access to any resource incurs a load cost.
- Cache lives for entire session (acceptable for single-player RPG).
- Error handling is explicit.

### Alternatives Considered
- **Eager loading (preload all at boot)**: Slow boot with 500+ resources.
- **Weak reference cache**: Over-engineered for immutable resources.
- **No cache**: Performance hit on repeated access.

---

## Template for New Decisions

```markdown
## ADR-NNN: Title

**Date**: YYYY-MM-DD
**Status**: Proposed

### Context
...

### Decision
...

### Rationale
...

### Consequences
...

### Alternatives Considered
- ...
```

---

## Related

- [architecture.md](architecture.md) — Architecture overview
- [technical_debt.md](technical_debt.md) — Technical debt tracking
