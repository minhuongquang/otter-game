---
description: How implementation work should be shaped
alwaysApply: true
---

# Implementation Rules

## Build Small Vertical Slices

Prefer complete playable increments over isolated infrastructure.

A useful slice connects player action, system response, and visible result.

## Reuse Before Creating

Before adding new code, search for relevant existing:

- managers
- components
- Resources
- utilities
- scenes
- docs

Extend existing patterns when they fit. Create new abstractions only when they reduce current complexity or prevent clear duplication.

## Prototype Discipline

Make the simplest change that satisfies the current requirement.

Avoid premature optimization, broad generalization, and feature completeness that the task did not request.

Temporary prototype code is allowed only when it is clearly isolated, easy to replace, and reported as such.

## Refactoring

Refactor when it is necessary for the task or removes local duplication introduced by the task.

Do not perform large unrelated refactors.

Do not rewrite stable systems unless the user requested it or the current task cannot be completed safely without it.

