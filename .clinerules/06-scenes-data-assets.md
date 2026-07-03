---
description: Scene, Resource, data, asset, and folder placement rules
globs:
  - "scenes/**/*"
  - "database/**/*"
  - "assets/**/*"
  - "scripts/**/*.gd"
  - "autoload/**/*.gd"
---

# Scenes, Data, And Assets

## Folders

Use the existing top-level structure:

```text
assets/
autoload/
database/
docs/
scenes/
scripts/
tests/
addons/
```

Create new folders only when they match an existing domain or are needed for a clear new domain.

## Scenes

Scenes should have one primary responsibility.

Reusable shared scenes belong under `scenes/` in the matching domain folder.

Feature-local sub-scenes may stay inside the feature folder when they are not intended for reuse elsewhere.

Do not duplicate scene structures when a reusable scene already exists.

## Scripts

Scripts should mirror scene or system ownership where practical.

Examples:

- `scenes/world/world_map.tscn`
- `scripts/world/world_map.gd`

Keep unrelated scripts out of the same folder.

## Resources And Data

Reusable game data belongs in `database/`.

Prefer Resources or data files for content that designers may expand:

- characters
- dialogue
- regions and maps
- items, shops, skills, enemies, and quests

Use stable IDs for data that may be referenced by saves, quests, dialogue, or other resources.

## Assets

Organize assets by type first, then domain.

Do not mix source assets, generated assets, and imported/editor-generated files unless the project already has a convention for that asset type.

Do not manually edit Godot-generated cache files under `.godot/`.

