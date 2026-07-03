---

description: Scene organization rules
globs:

* "scenes/**/*.tscn"

---

# Scene Philosophy

Scenes should be modular.

Each scene should have one clear purpose.

Avoid giant scene hierarchies.

---

# Reusable Scenes

Everything reusable should become its own scene.

Examples:

* NPC
* Chest
* Door
* Portal
* Dialogue Box
* Health Bar
* Inventory Slot

Never duplicate scene structures.

---

# Scene Ownership

A scene should own only its own children.

Avoid modifying unrelated scenes.

---

# Scene Communication

Use:

* Signals
* Managers
* Events

Avoid parent traversal whenever possible.

Bad:

```gdscript
get_parent().get_parent().get_parent()
```

---

# Scene Loading

Always load scenes through SceneManager.

Avoid changing scenes directly.

Support:

* Fade
* Async loading
* Loading screen

---

# Scene Size

If a scene becomes difficult to understand,

split it into reusable sub-scenes.

Readable scenes are preferred over fewer scenes.
