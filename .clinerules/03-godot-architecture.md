---
description: Godot-specific architecture boundaries and system ownership
alwaysApply: true
---

# Godot Architecture

## System Boundaries

Keep gameplay modules independent:

- Visual Novel
- World Navigation
- Exploration
- Battle
- RPG Systems
- Save System
- UI
- Audio

A system should own its own state. Other systems should interact through explicit APIs, signals, events, or data Resources.

Do not create parallel systems that solve the same problem as an existing system.

## Managers And Autoloads

Use managers or autoloads only for state or services that must be globally available.

Before adding one, check whether the behavior belongs in:

- an existing manager
- a scene-local script
- a Resource
- a reusable component
- the EventBus or signals

Do not create a manager for a one-off feature.

## Scene Communication

Prefer direct references for local parent-child scene ownership.

Prefer signals, EventBus, or manager APIs for cross-system communication.

Avoid deep parent traversal and hidden dependencies between unrelated scenes.

## Save-Facing Changes

Treat saved data as a public contract.

Before changing save keys, resource IDs, persistent flags, or serialized structures, identify migration or compatibility impact.

Do not break existing saves silently.

