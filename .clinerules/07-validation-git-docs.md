---
description: Completion checks, source control discipline, and documentation updates
alwaysApply: true
---

# Validation, Git, And Docs

## Validation

Before finishing, perform the most relevant validation available:

- inspect changed scripts for syntax and Godot 4 API correctness
- run project tests if they exist and are relevant
- run a Godot headless parse/test command if the executable is available
- describe manual test steps when automated validation is unavailable

Check likely regressions for changed areas, especially:

- scene references
- signals
- UI flow
- input
- save/load
- resource paths

Report validation honestly. Do not claim tests were run if they were not.

## Git Hygiene

Modify only files needed for the task.

Do not format unrelated files.

Do not revert user changes unless explicitly requested.

Keep commits, when requested, focused and reversible.

## Documentation

Read docs relevant to the task area; do not read the entire docs folder by default.

Update or recommend docs updates when a change affects:

- architecture
- public APIs
- data formats
- save behavior
- workflow or content pipeline

Use `docs/decisions.md` for significant architecture decisions.

