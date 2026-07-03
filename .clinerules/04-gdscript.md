---

description: GDScript coding standards
globs:

* "scripts/**/*.gd"

---

# GDScript Standards

Use typed GDScript whenever possible.

Example:

```gdscript
var current_hp: int = 100
var player_name: String
```

Avoid Variant unless necessary.

---

# Naming

Classes:

PascalCase

Variables:

snake_case

Functions:

snake_case

Constants:

UPPER_SNAKE_CASE

Signals:

snake_case

Enums:

PascalCase

---

# Script Organization

Order:

1. class_name
2. extends
3. signals
4. enums
5. constants
6. exported variables
7. public variables
8. private variables
9. _ready()
10. _process()
11. public methods
12. private methods

Keep every script organized consistently.

---

# Functions

Functions should do one thing.

Prefer small functions.

Avoid functions longer than ~40 lines unless justified.

Extract reusable logic.

---

# Comments

Comment WHY.

Avoid commenting WHAT.

Bad:

```gdscript
# Increase HP
hp += 10
```

Good:

```gdscript
# Temporary invulnerability after healing prevents chain damage.
```

---

# Node Access

Prefer:

@onready

Avoid repeated get_node().

Cache references.

---

# Performance

Avoid:

find_child()

get_tree().get_nodes_in_group()

inside _process().

Cache frequently used references.

---

# Signals

Prefer signals over direct references.

Avoid circular dependencies.

Never create tightly coupled gameplay systems.
