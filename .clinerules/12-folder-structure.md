---

description: Project folder organization and file placement
alwaysApply: true
-----------------

# Folder Structure

Maintain a clean and predictable project structure.

Do not create new folders unless they follow the existing architecture.

Preferred structure:

```text
project/

assets/
    art/
    audio/
    fonts/
    shaders/
    vfx/

autoload/

database/
    dialogue/
    enemies/
    items/
    maps/
    quests/
    regions/
    skills/

docs/

scenes/
    battle/
    characters/
    exploration/
    ui/
    world/

scripts/
    battle/
    core/
    managers/
    ui/
    world/
    components/
    utilities/

tests/

addons/
```

---

# Scene Placement

Every reusable scene belongs in:

scenes/

Examples:

* NPC
* Portal
* Chest
* DialogueBox
* InventorySlot

Avoid placing reusable scenes inside feature-specific folders.

---

# Script Placement

Scripts should mirror the scene structure whenever practical.

Example:

```text
scenes/world/
    WorldMap.tscn

scripts/world/
    world_map.gd
```

Avoid storing unrelated scripts together.

---

# Resources

Store reusable Resources inside:

database/

Examples:

* Character Resources
* Enemy Resources
* Skill Resources
* Item Resources

Game data should not be embedded inside scripts.

---

# Assets

Never mix source assets with generated assets.

Organize assets by type first, then feature.

Example:

assets/art/characters/

assets/audio/bgm/

assets/audio/sfx/

---

# Documentation

All documentation belongs inside:

docs/

Never store design notes inside source folders.

---

# Naming

Use:

snake_case

for:

* folders
* scenes
* scripts
* resources

Use PascalCase only for class_name declarations.

---

# Goal

A new developer should understand the project layout within a few minutes without additional explanation.
