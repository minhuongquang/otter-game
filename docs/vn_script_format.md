# VN Script Format

> **Purpose**: Define the `.dialogue` script syntax for writers.  
> **Scope**: All commands and syntax rules for creating VN dialogue scripts.  
> **Status**: Final.  
> **Last Updated**: 2026-07-05

---

## File Format Overview

Dialogue scripts use a custom text format with the `.dialogue` extension. Files are compiled into `VNDialogueResource` (`.tres`) by `VNScriptCompiler` before being loaded by the game.

### Basic Structure

```
[META]
metadata here

[CHARACTERS]
character definitions here

[VARIABLES]
variable definitions here

[SCRIPT]
dialogue commands here
```

---

## Sections

### [META]

Defines dialogue-level metadata.

```
id: "prologue_001"                                    # Unique dialogue ID (required)
bg: "res://assets/art/backgrounds/castle_hall.png"    # Default background image
bgm: "res://assets/audio/bgm/melancholy.ogg"          # Default BGM
on_start: [...]                                       # Events to execute on dialogue start
on_end: [...]                                         # Events to execute on dialogue end
```

**on_start / on_end events** use JSON format:

```
on_end: [{"type": "set_flag", "key": "prologue_seen", "value": true}]
on_start: [{"type": "unlock_region", "region_id": "castle"}]
```

### [CHARACTERS]

Defines short aliases for character resources. Used in LINE commands.

```
saria = "res://database/characters/saria.tres"
lyra = "res://database/characters/lyra.tres"
```

### [VARIABLES]

Defines dialogue-local variables with initial values.

```
trust_level: 0
met_saria: false
player_name: ""
```

Variables are scoped to the current dialogue and reset when it starts.

### [SCRIPT]

Contains all dialogue commands and branching logic.

---

## Commands Reference

### LINE — Display dialogue text

```
LINE speaker_id "Display Name" emotion "Dialogue text here"
```

| Field | Description |
|-------|-------------|
| `speaker_id` | Character alias from [CHARACTERS] |
| `Display Name` | Name shown in the dialogue box (quoted) |
| `emotion` | Character expression (neutral, happy, sad, angry, smile, excited, etc.) |
| `Dialogue text` | The spoken text (quoted). Supports BBCode. |

**Examples:**
```
LINE saria "Saria" smile "Hello there!"
LINE saria "Saria" neutral "This text has [color=red]BBCode[/color] support."
```

### SHOW — Show a character portrait

```
SHOW character_id position [animation]
```

| Field | Description |
|-------|-------------|
| `character_id` | Character alias |
| `position` | `far_left`, `left`, `center`, `right`, `far_right` |
| `animation` | `fade_in` (default), `slide_left`, `slide_right`, `none` |

**Example:**
```
SHOW lyra right fade_in
```

### HIDE — Hide a character portrait

```
HIDE character_id [animation]
```

| Field | Description |
|-------|-------------|
| `character_id` | Character alias |
| `animation` | `fade_out` (default), `none` |

**Example:**
```
HIDE lyra fade_out
```

### EXPR — Change character expression

```
EXPR character_id emotion
```

**Example:**
```
EXPR lyra excited
EXPR saria angry
```

### BACKGROUND — Change background

```
BACKGROUND "texture_path" transition duration
```

| Field | Description |
|-------|-------------|
| `texture_path` | Path to the background image |
| `transition` | `fade`, `dissolve`, `none` |
| `duration` | Transition duration in seconds |

**Example:**
```
BACKGROUND "res://assets/art/backgrounds/garden.png" FADE 1.0
```

### BGM — Play background music

```
BGM "audio_path" fade_in
```

**Example:**
```
BGM "res://assets/audio/bgm/exploration.ogg" 0.5
```

### STOP_BGM — Stop background music

```
STOP_BGM fade_out
```

**Example:**
```
STOP_BGM 1.0
```

### SFX — Play sound effect

```
SFX "audio_path" [volume]
```

**Example:**
```
SFX "res://assets/audio/sfx/door_creak.ogg"
SFX "res://assets/audio/sfx/footstep.ogg" -5.0
```

### SHAKE — Camera shake

```
SHAKE intensity duration
```

**Example:**
```
SHAKE 0.3 0.5
```

### FADE — Screen fade

```
FADE target_color duration
```

| Field | Description |
|-------|-------------|
| `target_color` | `black`, `white`, or hex color |
| `duration` | Fade duration in seconds |

**Example:**
```
FADE black 1.0
```

### GIVE_ITEM — Give item to player

```
GIVE_ITEM item_id quantity
```

**Example:**
```
GIVE_ITEM old_map 1
GIVE_ITEM potion_small 3
```

### START_BATTLE — Trigger a battle

```
START_BATTLE enemy_group_id
```

**Example:**
```
START_BATTLE training_dummy
```

### UNLOCK_REGION — Unlock a region

```
UNLOCK_REGION region_id
```

**Example:**
```
UNLOCK_REGION castle_interior
```

### CUTSCENE — Start a cutscene

```
CUTSCENE cutscene_id
```

**Example:**
```
CUTSCENE intro_flyover
```

### SET_FLAG — Set a story flag (persistent)

```
SET_FLAG flag_name value
```

**Example:**
```
SET_FLAG met_saria true
SET_FLAG chapter 2
```

### SET_VAR — Set a dialogue-local variable

```
SET_VAR var_name operator value
```

Operators: `assign`, `add`, `subtract`, `multiply`, `divide`

**Examples:**
```
SET_VAR trust_level add 5
SET_VAR trust_level subtract 2
SET_VAR met_saria assign true
```

### WAIT — Pause execution

```
WAIT duration
```

**Example:**
```
WAIT 1.0
WAIT 0.5
```

### LABEL — Define a jump target

```
LABEL label_name
```

**Example:**
```
LABEL start
LABEL after_choice
```

### JUMP — Jump to a label (unconditional)

```
JUMP label_name
```

**Example:**
```
JUMP after_intro
```

### BRANCH — Conditional branch

```
BRANCH condition JUMP label_name
```

**Condition format:** `variable_name operator value`

Supported operators: `==`, `!=`, `>=`, `<=`, `>`, `<`

Variables prefixed with `flag_` or `story_` read from GlobalFlags. All others read from local variables.

**Examples:**
```
BRANCH trust_level >= 5 JUMP good_ending
BRANCH flag_met_saria == true JUMP greeting_again
BRANCH flag_chapter >= 2 JUMP chapter_two
BRANCH else JUMP default_path
```

### CHOICE — Display player choice

```
CHOICE "Choice text"
    [effects]
    JUMP target_label

CHOICE "Another choice"
    JUMP other_label
```

**Effects within choices:**
```
CHOICE "I agree."
    SET_FLAG agreed true
    SET_VAR trust_level add 5
    JUMP agree_path

CHOICE "I refuse."
    SET_FLAG refused true
    JUMP refuse_path
```

### ANIM — Play animation

```
ANIM target animation_id [params]
```

| Field | Description |
|-------|-------------|
| `target` | Character alias or `background` |
| `animation_id` | `bounce`, `shake`, `flash` |
| `params` | Optional key=value pairs |

**Examples:**
```
ANIM lyra bounce
ANIM background shake
```

---

## Comments

Use `#` for comments. Everything after `#` on a line is ignored.

```
# This is a comment
LINE saria "Saria" neutral "Hello"  # This is also a comment
```

---

## Full Example

```
[META]
id: "prologue_001"
bg: "res://assets/art/backgrounds/castle_hall.png"
bgm: "res://assets/audio/bgm/melancholy.ogg"
on_end: [{"type": "set_flag", "key": "prologue_seen", "value": true}]

[CHARACTERS]
saria = "res://database/characters/saria.tres"
lyra = "res://database/characters/lyra.tres"

[VARIABLES]
trust_level: 0

[SCRIPT]
LABEL start

LINE saria "Saria" smile "Welcome, traveler."

BRANCH flag_prologue_seen == true JUMP greeting_again

LINE saria "Saria" neutral "This is your first time here."

CHOICE "I'm new."
    JUMP after_intro

CHOICE "I've been here before."
    SET_VAR trust_level add 5
    JUMP after_intro

LABEL greeting_again
LINE saria "Saria" happy "Welcome back!"

LABEL after_intro
SHOW lyra right fade_in
LINE lyra "Lyra" happy "Hey there!"
```

---

## Compilation

Compile `.dialogue` files using `VNScriptCompiler`:

```gdscript
var compiler := VNScriptCompiler.new()
var resource := compiler.compile_file("res://database/dialogue/prologue.dialogue")
if resource:
    compiler.save_resource(resource, "res://database/dialogue/compiled/prologue.tres")
```

The compiled `.tres` files are loaded at runtime by the `Database` autoload.