---
description: GDScript coding rules
globs:
  - "scripts/**/*.gd"
  - "autoload/**/*.gd"
---

# GDScript Style

Use typed GDScript where practical.

Naming:

- `PascalCase` for `class_name` and enums
- `snake_case` for variables, functions, signals, files, and folders
- `UPPER_SNAKE_CASE` for constants

Script order:

1. `class_name`
2. `extends`
3. signals
4. enums
5. constants
6. exported variables
7. public variables
8. private variables
9. lifecycle methods
10. public methods
11. private methods

Functions should have one clear responsibility. Split long functions when the split improves readability.

Comment why a non-obvious choice exists. Do not comment obvious code.

Use `@onready` or exported references for node access that is reused.

Do not call expensive tree searches such as `find_child()` or broad group scans inside `_process()` unless the result is cached or the cost is intentional.

Prefer signals for decoupled gameplay events. Avoid circular dependencies.

