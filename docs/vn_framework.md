# Visual Novel Framework

> **Purpose**: Document the Visual Novel dialogue system architecture, components, and data flow.  
> **Scope**: VNManager, VNStateMachine, VNCommandExecutor, VNVariableStore, VNTypewriter, VNAutoSkip, VNHistory, VNScriptCompiler, and all VNCommand types.  
> **Status**: Implemented.

---

## Architecture Overview

The VN framework follows a **Command Pattern** architecture with a **two-pass compilation** pipeline.

```
.dialogue (text) ──▶ VNScriptCompiler ──▶ VNDialogueResource (.tres) ──▶ VNManager ──▶ VNStateMachine
                                                                              │
                                                                              ├─ VNCommandExecutor
                                                                              ├─ VNVariableStore
                                                                              ├─ VNTypewriter
                                                                              ├─ VNAutoSkip
                                                                              └─ VNHistory
```

### Key Design Decisions

| Decision | Rationale |
|----------|-----------|
| **Text-based `.dialogue` format** | Writers cannot edit `.tres` files efficiently. A text format with compiler is far more productive for thousands of dialogue lines. |
| **Command Pattern** | Every action (show_character, play_bgm, shake_camera) is a `VNCommand`. Adding a new command requires only a new command class, no manager changes. |
| **State Machine** | Clear separation of states (TYPING, WAITING, CHOICE, COMMAND). Prevents spaghetti logic in the VN scene. |
| **Two-pass compilation** | First pass resolves labels and branches. Second pass builds the final command array. No runtime parsing overhead. |
| **EventBus communication** | VNManager emits events for UI, audio, and game systems. No direct coupling between VN and other systems. |

---

## Class Hierarchy

```
VNCommand (base, Resource)
├── VNCmdDialogueLine
├── VNCmdShowCharacter
├── VNCmdHideCharacter
├── VNCmdChangeExpression
├── VNCmdBackground
├── VNCmdPlayBGM
├── VNCmdStopBGM
├── VNCmdPlaySFX
├── VNCmdShakeCamera
├── VNCmdFade
├── VNCmdGiveItem
├── VNCmdStartBattle
├── VNCmdUnlockRegion
├── VNCmdStartCutscene
├── VNCmdSetFlag
├── VNCmdSetVariable
├── VNCmdBranch
├── VNCmdChoice
├── VNCmdAnimation
├── VNCmdWait
└── VNCmdLabel (internal)

VNChoiceData (Resource) — data for a single choice option

VNDialogueResource (Resource) — compiled dialogue with command array

VNScriptCompiler (RefCounted) — compiles .dialogue text → VNDialogueResource
```

### Manager Classes

```
VNManager (Node, scene-based)
├── VNStateMachine (Node) — execution flow control
├── VNCommandExecutor (Node) — dispatches commands to handlers
├── VNVariableStore (RefCounted) — local variables + condition evaluation
├── VNTypewriter (Node) — character-by-character text reveal
├── VNAutoSkip (Node) — auto-advance and skip mode
└── VNHistory (RefCounted) — dialogue history storage
```

---

## Data Flow

```
1. Trigger (NPC interaction, quest update, cutscene)
   │
   ▼
2. SceneManager transitions to visual_novel.tscn
   │
   ▼
3. VNManager.start_dialogue("prologue_001")
   │
   ▼
4. Database loads VNDialogueResource (compiled .tres)
   │
   ▼
5. VNStateMachine.run(commands)
   │
   ▼
6. For each command:
   ├─ DialogueLine → VNTypewriter.start_display() → TYPING state
   ├─ Choice → VNChoicePanel shows buttons → CHOICE state
   ├─ Branch → VNVariableStore.evaluate_condition() → jump or continue
   ├─ Blocking cmd → VNCommandExecutor.execute() → wait for completion
   └─ Non-blocking cmd → VNCommandExecutor.execute() → continue immediately
   │
   ▼
7. Dialogue ends → VNManager.end_dialogue() → return to gameplay
```

---

## State Machine States

| State | Description |
|-------|-------------|
| `IDLE` | Not running any dialogue |
| `TYPING` | Typewriter effect is playing |
| `WAITING` | Waiting for player input (click or auto-timer) |
| `CHOICE` | Waiting for player to select a choice |
| `COMMAND` | Executing a blocking command (fade, wait, shake) |
| `SKIPPING` | Skip mode active, rapidly iterating through commands |
| `PAUSED` | Game paused (VN is suspended) |
| `ENDED` | Dialogue sequence complete |

---

## EventBus Events

| Event | Data | Emitter | Purpose |
|-------|------|---------|---------|
| `vn_started` | `{ "dialogue_id": String }` | VNManager | Dialogue started |
| `vn_ended` | `{ "dialogue_id": String }` | VNManager | Dialogue ended |
| `vn_advance` | `{}` | Input | Player wants to advance |
| `vn_make_choice` | `{ "index": int }` | UI | Player made a choice |
| `vn_toggle_auto` | `{}` | UI | Toggle auto mode |
| `vn_toggle_skip` | `{}` | UI | Toggle skip mode |
| `vn_open_history` | `{}` | UI | Open history log |
| `vn_show_choices` | `{ "choices": Array }` | VNManager | Display choice buttons |
| `vn_show_history` | `{ "entries": Array }` | VNManager | Display history |
| `vn_change_background` | `{ "texture_path", "transition", "duration" }` | Executor | Change background |
| `vn_show_character` | `{ "character_id", "position", "animation" }` | Executor | Show character |
| `vn_hide_character` | `{ "character_id", "animation" }` | Executor | Hide character |
| `vn_change_expression` | `{ "character_id", "emotion" }` | Executor | Change expression |
| `vn_play_bgm` | `{ "audio_path", "fade_in" }` | Executor | Play background music |
| `vn_stop_bgm` | `{ "fade_out" }` | Executor | Stop background music |
| `vn_play_sfx` | `{ "audio_path", "volume" }` | Executor | Play sound effect |
| `vn_shake_camera` | `{ "intensity", "duration" }` | Executor | Camera shake |
| `vn_fade` | `{ "target_color", "duration" }` | Executor | Screen fade |
| `vn_give_item` | `{ "item_id", "quantity" }` | Executor | Give item to player |
| `vn_start_battle` | `{ "enemy_group_id" }` | Executor | Start battle |
| `vn_unlock_region` | `{ "region_id" }` | Executor | Unlock region |
| `vn_start_cutscene` | `{ "cutscene_id" }` | Executor | Start cutscene |
| `vn_animation` | `{ "target", "animation_id", "params" }` | Executor | Play animation |

---

## Custom Command Registration

Any system can register custom dialogue commands at runtime:

```gdscript
# In any script:
VNCommandExecutor.register_handler("my_custom_command", _handle_my_command)

func _handle_my_command(command: VNCommand, executor: VNCommandExecutor) -> bool:
    var params: Dictionary = command.get_params()
    # Custom logic here
    return false  # false = non-blocking, true = blocking
```

This allows mods, DLC, or new features to add dialogue commands without modifying VN system code.

---

## Save System Integration

VNManager provides `serialize()` and `deserialize()` methods:

```gdscript
# Save
var vn_data: Dictionary = vn_manager.serialize()
save_data["vn_state"] = vn_data

# Load
if save_data.has("vn_state"):
    vn_manager.deserialize(save_data["vn_state"])
```

Serialized data includes:
- Current dialogue ID
- Current command index
- Local variables
- Read lines tracking (for skip mode)

---

## File Locations

| File | Path |
|------|------|
| Base command class | `scripts/core/vn/vn_command.gd` |
| Dialogue resource | `scripts/core/vn/vn_dialogue_resource.gd` |
| Choice data | `scripts/core/vn/vn_choice_data.gd` |
| Script compiler | `scripts/core/vn/vn_script_compiler.gd` |
| Command classes | `scripts/core/vn/vn_commands/*.gd` |
| VNManager | `scripts/managers/vn/vn_manager.gd` |
| State machine | `scripts/managers/vn/vn_state_machine.gd` |
| Command executor | `scripts/managers/vn/vn_command_executor.gd` |
| Variable store | `scripts/managers/vn/vn_variable_store.gd` |
| Typewriter | `scripts/managers/vn/vn_typewriter.gd` |
| Auto/Skip | `scripts/managers/vn/vn_auto_skip.gd` |
| History | `scripts/managers/vn/vn_history.gd` |
| UI panel | `scripts/ui/vn/vn_panel.gd` |
| Dialogue scripts | `database/dialogue/*.dialogue` |
| Compiled resources | `database/dialogue/compiled/*.tres` |

---

## Related

- [vn_script_format.md](vn_script_format.md) — Dialogue script syntax
- [vn_commands.md](vn_commands.md) — Command reference for writers
- [architecture.md](architecture.md) — System architecture
- [managers.md](managers.md) — Manager documentation
- [event_system.md](event_system.md) — Event system
- [database.md](database.md) — Data architecture