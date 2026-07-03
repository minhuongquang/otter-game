# VN Commands Reference

> **Purpose**: Quick reference for all VN dialogue commands.  
> **Scope**: All 20 built-in commands plus custom command registration.  
> **Status**: Final.

---

## Command Table

| Command | Syntax | Blocking | Description |
|---------|--------|----------|-------------|
| **LINE** | `LINE speaker_id "Name" emotion "text"` | Yes | Display dialogue text |
| **SHOW** | `SHOW character_id position [anim]` | Yes* | Show character portrait |
| **HIDE** | `HIDE character_id [anim]` | Yes* | Hide character portrait |
| **EXPR** | `EXPR character_id emotion` | No | Change character expression |
| **BACKGROUND** | `BACKGROUND "path" transition dur` | Yes | Change background image |
| **BGM** | `BGM "path" fade_in` | No | Play background music |
| **STOP_BGM** | `STOP_BGM fade_out` | No | Stop background music |
| **SFX** | `SFX "path" [volume]` | No | Play sound effect |
| **SHAKE** | `SHAKE intensity duration` | Yes | Camera shake effect |
| **FADE** | `FADE color duration` | Yes | Screen fade effect |
| **GIVE_ITEM** | `GIVE_ITEM item_id quantity` | No | Give item to player |
| **START_BATTLE** | `START_BATTLE group_id` | Yes | Trigger battle encounter |
| **UNLOCK_REGION** | `UNLOCK_REGION region_id` | No | Unlock region on world map |
| **CUTSCENE** | `CUTSCENE cutscene_id` | Yes | Start cinematic cutscene |
| **SET_FLAG** | `SET_FLAG key value` | No | Set persistent story flag |
| **SET_VAR** | `SET_VAR key op value` | No | Set dialogue-local variable |
| **WAIT** | `WAIT duration` | Yes | Pause execution |
| **LABEL** | `LABEL name` | No | Define branch target (internal) |
| **JUMP** | `JUMP label_name` | No | Unconditional branch |
| **BRANCH** | `BRANCH cond JUMP label` | No | Conditional branch |
| **CHOICE** | `CHOICE "text"` then effects + JUMP | Yes | Player choice point |
| **ANIM** | `ANIM target anim_id [params]` | Yes* | Play animation on element |
| **#** | `# comment` | No | Comment (ignored) |

\* Blocking only when an animation/transition is specified.

---

## Command Class Mapping

| Command Type | GDScript Class |
|-------------|----------------|
| `dialogue_line` | `VNCmdDialogueLine` |
| `show_character` | `VNCmdShowCharacter` |
| `hide_character` | `VNCmdHideCharacter` |
| `change_expression` | `VNCmdChangeExpression` |
| `background` | `VNCmdBackground` |
| `play_bgm` | `VNCmdPlayBGM` |
| `stop_bgm` | `VNCmdStopBGM` |
| `play_sfx` | `VNCmdPlaySFX` |
| `shake_camera` | `VNCmdShakeCamera` |
| `fade` | `VNCmdFade` |
| `give_item` | `VNCmdGiveItem` |
| `start_battle` | `VNCmdStartBattle` |
| `unlock_region` | `VNCmdUnlockRegion` |
| `start_cutscene` | `VNCmdStartCutscene` |
| `set_flag` | `VNCmdSetFlag` |
| `set_variable` | `VNCmdSetVariable` |
| `branch` | `VNCmdBranch` |
| `choice` | `VNCmdChoice` |
| `animation` | `VNCmdAnimation` |
| `wait` | `VNCmdWait` |
| `label` | `VNCmdLabel` |

---

## Adding Custom Commands

Custom commands can be registered at runtime from any script:

```gdscript
# 1. Create a command class (optional - can also parse inline)
class_name VNCmdMyCustom
extends VNCommand

@export var my_param: String = ""

func _init() -> void:
    command_type = "my_custom"
    blocking = false


# 2. Register a handler
VNCommandExecutor.register_handler("my_custom", _handle_my_custom)

func _handle_my_custom(command: VNCommand, executor: VNCommandExecutor) -> bool:
    var cmd: VNCmdMyCustom = command as VNCmdMyCustom
    if cmd == null:
        return false
    
    # Custom logic here
    print("Custom command executed with param: ", cmd.my_param)
    
    return false  # false = non-blocking, true = blocking
```

### Custom Command Registration API

```gdscript
## Register a handler for a command type.
## Parameters:
##   command_type: String matching the command's command_type field
##   handler: Callable(command: VNCommand, executor: VNCommandExecutor) -> bool
## Returns: void
func register_handler(command_type: String, handler: Callable) -> void
```

The handler function receives:
- `command`: The VNCommand instance with command-specific data
- `executor`: The VNCommandExecutor (for calling `on_blocking_command_finished()`)

Returns:
- `true` if the command is blocking (executor will wait for `on_blocking_command_finished()`)
- `false` if the command completes immediately