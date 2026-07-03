# Coding Guidelines

> **Purpose**: Define code conventions, naming rules, and GDScript standards for consistency.  
> **Scope**: All GDScript files in the project.  
> **Status**: Draft — to be enforced through code review.

---

## Language

All gameplay code must be written in **GDScript 2.0** (Godot 4.x).

Do not use C# unless explicitly requested.

Do not use Godot 3 syntax or deprecated APIs.

---

## Naming Conventions

| Element | Convention | Example |
|---------|------------|---------|
| Files | snake_case | `player_controller.gd` |
| Folders | snake_case | `scenes/battle/` |
| Classes | PascalCase | `class_name BattleManager` |
| Signals | snake_case | `signal battle_started` |
| Methods | snake_case | `func take_damage(amount: int)` |
| Variables | snake_case | `var current_hp: int` |
| Constants | UPPER_SNAKE | `const MAX_HP: int = 999` |
| Enums | PascalCase | `enum ElementType` |
| Enum Values | UPPER_SNAKE | `ElementType.FIRE` |
| Exports | snake_case | `@export var damage: int` |
| Private | prefix `_` | `var _health: int` |
| Node Paths | snake_case | `@onready var _label = $HUD/Label` |

---

## File Organization

Every script should follow this structure:

```gdscript
# === Class Declaration ===
class_name MyClass
extends Node

# === Documentation ===
## Brief description of this class.
## Responsibilities, usage notes.

# === Signals ===
signal my_signal(value: int)

# === Enums ===
enum State { IDLE, ACTIVE, COOLDOWN }

# === Constants ===
const MAX_VALUE: int = 100

# === Exports ===
@export var speed: float = 200.0
@export_group("Combat")
@export var damage: int = 10

# === Public Variables ===
var current_value: int = 0

# === Private Variables ===
var _state: State = State.IDLE
@onready var _sprite: Sprite2D = $Sprite2D

# === Built-in Overrides ===
func _ready() -> void:
    pass

func _process(delta: float) -> void:
    pass

# === Public Methods ===
func do_something() -> void:
    pass

# === Private Methods ===
func _internal_logic() -> void:
    pass
```

---

## Type Annotations

All variables, parameters, and return types must be annotated.

```gdscript
# Correct
var name: String = ""
func add(a: int, b: int) -> int:
    return a + b

# Avoid
var name = ""
func add(a, b):
    return a + b
```

Use `-> void` for methods that return nothing.

Use `Variant` only when the type is truly dynamic.

---

## String Usage

- Use **double quotes** for strings: `"hello"`.
- Use `String` type annotations: `var name: String`.
- Prefer string formatting over concatenation:
  ```gdscript
  # Preferred
  var text: String = "HP: %d/%d" % [current, max]
  
  # Avoid
  var text: String = "HP: " + str(current) + "/" + str(max)
  ```

---

## Resource Usage

Prefer typed resources over dictionaries:

```gdscript
# Preferred
@export var item_data: ItemResource

# Avoid
@export var item_data: Dictionary
```

Resources are Godot's native data container. They are:
- Type-safe
- Inheritable
- Hot-reloadable
- Serializable

---

## Node References

```gdscript
# Preferred
@onready var health_bar: ProgressBar = $UI/HealthBar

# Avoid in _ready
func _ready() -> void:
    health_bar = $UI/HealthBar
```

Use `@onready` for node references. Use `$` for direct children. Use `get_node()` for dynamic paths.

---

## Signals

```gdscript
# Declaration
signal health_changed(old_hp: int, new_hp: int)

# Emission
health_changed.emit(_hp, new_hp)

# Connection (prefer one-liners)
health_changed.connect(_on_health_changed)
```

- Signals are `snake_case`.
- Signal parameters are typed.
- Connect signals in `_ready()` or `@onready` blocks.
- Use one-liner connections for simple cases.
- Use Callables for complex connections.

---

## Comments

```gdscript
# === Section Headers ===

## Documentation comments above class/function declarations
func example() -> void:
    # Inline explanation for non-obvious logic
    pass
```

- Write **why**, not **what**.
- Prefer self-documenting code over comments.
- Remove commented-out code before committing.
- Use `##` for public-facing doc comments.

---

## Error Handling

```gdscript
# Prefer early returns
if not is_instance_valid(target):
    return

# Assert for invariants
assert(hp >= 0, "HP cannot be negative")

# Log meaningful errors
if not file_loaded:
    push_error("Failed to load file: %s" % file_path)
```

- Use `push_error()` for recoverable errors.
- Use `assert()` for programming errors that should never happen.
- Use `return` early to avoid deep nesting.
- Log messages should include context for debugging.

---

## Architecture Rules

- **One class per file** (except small helper enums/constants).
- **No circular dependencies.**
- **No global variables** outside autoloads.
- **No hardcoded content** in scripts.
- **No magic numbers** — use constants or enums.
- **No `print()` in production code** — use logging.

---

## File Sizes

- Keep scripts under 300 lines where practical.
- If a script exceeds 300 lines, consider splitting.
- UI scripts should be under 150 lines (logic should be in managers).

---

## Git Commit Format

```
type: Brief description

Optional longer explanation.

Related: #issue-number
```

Types: `feat`, `fix`, `refactor`, `docs`, `style`, `test`, `chore`

---

## Related

- [folder_structure.md](folder_structure.md) — Where files go
- [scene_architecture.md](scene_architecture.md) — Scene composition patterns
- [testing.md](testing.md) — Testing requirements
