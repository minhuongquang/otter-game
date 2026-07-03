---
description: Project identity and durable product constraints
alwaysApply: true
---

# Project Context

This is a Godot 4.x 2D RPG + Visual Novel hybrid written primarily in GDScript.

The project is currently a prototype, but decisions should not block a future commercial-quality game.

Expected long-term systems include:

- visual novel dialogue
- world navigation and exploration
- turn-based battles
- inventory, equipment, quests, shops, crafting, and relationships
- save/load
- localization and controller support

## Data-Driven Content

Game content should usually be data-driven through Resources or data files, not hardcoded in scripts.

Prefer data for:

- characters and NPCs
- dialogue
- items, equipment, skills, and enemies
- quests, shops, regions, and maps

Hardcoding is acceptable for prototype-only wiring, UI behavior, constants, and logic that is not content.

## Project Phase

Prioritize playable vertical slices and clear architecture over complete systems.

Avoid designing for hypothetical future cases unless the current change would otherwise create obvious rework.

