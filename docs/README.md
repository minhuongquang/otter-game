# SariaMod — Documentation

> **Project**: 2D RPG + Visual Novel Hybrid  
> **Engine**: Godot 4.x Stable  
> **Language**: GDScript 2.0  
> **Target**: Windows 11 (future: Steam, controller, localization)  
> **Status**: Pre-Production

---

## Quick Navigation

| Document | Purpose |
|----------|---------|
| [architecture.md](architecture.md) | System architecture, module relationships, data flow |
| [game_design.md](game_design.md) | Core game design, mechanics, player experience |
| [coding_guidelines.md](coding_guidelines.md) | Code conventions, naming, GDScript standards |
| [folder_structure.md](folder_structure.md) | Physical folder layout and rules |
| [scene_architecture.md](scene_architecture.md) | Scene tree patterns, composition, reuse |
| [autoloads.md](autoloads.md) | Global singletons, lifecycle |
| [managers.md](managers.md) | Manager classes, APIs, dependencies |
| [database.md](database.md) | Data-driven architecture, resources |
| [event_system.md](event_system.md) | Event bus, signals, communication |
| [dialogue_system.md](dialogue_system.md) | Visual Novel system |
| [battle_system.md](battle_system.md) | Turn-based combat system |
| [exploration_system.md](exploration_system.md) | 2D side-scrolling exploration |
| [quest_system.md](quest_system.md) | Quest lifecycle and management |
| [inventory_system.md](inventory_system.md) | Items, equipment, crafting |
| [save_system.md](save_system.md) | Save/load, versioning, cloud |
| [ui_system.md](ui_system.md) | UI framework, components, theming |
| [audio_system.md](audio_system.md) | Audio management, buses, dynamic |
| [resource_pipeline.md](resource_pipeline.md) | Asset creation and import pipeline |
| [content_pipeline.md](content_pipeline.md) | Content authoring workflow |
| [localization.md](localization.md) | Localization architecture |
| [input_system.md](input_system.md) | Input mapping, controller support |
| [testing.md](testing.md) | Testing strategy, validation |
| [current_tasks.md](current_tasks.md) | Active task tracking |
| [roadmap.md](roadmap.md) | Future milestones and versions |
| [decisions.md](decisions.md) | Architecture decision records |
| [technical_debt.md](technical_debt.md) | Known issues and cleanup |
| [release_checklist.md](release_checklist.md) | Release verification process |

---

## How to Use This Documentation

### For New Developers

Start here, then read in order:

1. [game_design.md](game_design.md) — Understand the game.
2. [architecture.md](architecture.md) — Understand the system.
3. [folder_structure.md](folder_structure.md) — Find your way around.
4. [coding_guidelines.md](coding_guidelines.md) — Write correct code.
5. [scene_architecture.md](scene_architecture.md) — Build scenes correctly.

Then read the feature document relevant to your current task.

### For Contributors Adding Features

1. Check [current_tasks.md](current_tasks.md) for active work.
2. Read the relevant feature document (dialogue, battle, etc.).
3. Read [event_system.md](event_system.md) for integration.
4. Read [database.md](database.md) for data-driven patterns.
5. Update [technical_debt.md](technical_debt.md) if you introduce known issues.
6. Update [decisions.md](decisions.md) for architectural choices.

### For Reviewers

1. Verify against [coding_guidelines.md](coding_guidelines.md).
2. Verify architecture against [architecture.md](architecture.md).
3. Check [testing.md](testing.md) for validation requirements.

---

## Project Principles

- **Data-driven**: Content is data, not code.
- **Modular**: Systems are independent and communicate through signals/events.
- **Scalable**: Architecture supports 3+ regions, hundreds of NPCs, thousands of dialogue lines.
- **Maintainable**: Readability over cleverness. SOLID, DRY, KISS.
- **Future-ready**: Localization, DLC, controller, cloud saves considered from day one.

---

## Development Environment

| Component | Specification |
|-----------|---------------|
| OS | Windows 11 Pro (64-bit) |
| Engine | Godot 4.x Stable |
| Language | GDScript 2.0 |
| IDE | Visual Studio Code |
| Version Control | Git + GitHub |
| Shell | PowerShell |

---

## Quick Start

```powershell
# Clone the repository
git clone <repository-url>

# Open in Godot
# Launch Godot 4.x and import project.godot from the project root.

# Open in VS Code
code D:\SariaMod

# Enable Godot GDScript extension for syntax highlighting
```

---

## Related

- [architecture.md](architecture.md) — System overview
- [current_tasks.md](current_tasks.md) — What is being worked on now
- [roadmap.md](roadmap.md) — Where the project is going
