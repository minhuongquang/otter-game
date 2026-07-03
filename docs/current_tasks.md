# Current Tasks

> **Purpose**: Track active development tasks, priorities, and assignees.  
> **Type**: Living document — update as tasks change.  
> **Last Updated**: 2026-06-30

---

## How to Use

- Add new tasks under the appropriate category.
- Mark tasks as [DONE] when complete.
- Move completed tasks to the "Completed" section.
- Update weekly.

---

## Active Sprint

### Priority 1 (This Week — COMPLETED)

| Task | Status | Assignee | Notes |
|------|--------|----------|-------|
| Set up project.godot configuration | ✅ DONE | AI | 7 autoloads, input map, display settings |
| Create folder structure | ✅ DONE | AI | All folders created per docs |
| Implement EventBus | ✅ DONE | AI | Core autoload |
| Implement Database | ✅ DONE | AI | Lazy loading with cache |
| Create Boot scene | ✅ DONE | AI | Splash + transition to main menu |
| Create MainMenu scene | ✅ DONE | AI | New Game, Load, Settings, Quit |
| Implement SaveManager | ✅ DONE | AI | JSON-based save/load |
| Implement AudioManager | ✅ DONE | AI | BGM, SFX, bus management |
| Implement InputManager | ✅ DONE | AI | Input context system |
| Implement UIManager | ✅ DONE | AI | Screen stack, HUD, notifications |
| Implement SceneManager | ✅ DONE | AI | Scene transitions, fades |
| Core resource definitions | ✅ DONE | AI | 9 resource class definitions |
| Architecture documentation | ✅ DONE | AI | 7 docs updated |
| ADR-006 and ADR-007 | ✅ DONE | AI | SceneManager + Lazy Loading |
| **Visual Novel Framework** | ✅ DONE | AI | Full VN system with 37 files |

### Priority 2 (Completed — moved to VN Framework)

| Task | Status | Assignee | Notes |
|------|--------|----------|-------|
| DialogueManager → VNManager | ✅ DONE | AI | Replaced with full VN framework |
| VN scene scripts | ✅ DONE | AI | 20 command classes, compiler, state machine |
| VN UI scripts | ✅ DONE | AI | Panel, portrait, typewriter, auto/skip, history |
| VN documentation | ✅ DONE | AI | 3 docs: framework, script format, commands |
| VN sample dialogue | ✅ DONE | AI | sample_prologue.dialogue with all command types |
| Bug fixes | ✅ DONE | AI | 9 bugs fixed across core/managers/ui |

### Priority 3 (Next)

| Task | Status | Assignee | Notes |
|------|--------|----------|-------|
| Create VN scenes in Godot Editor | TODO | — | visual_novel.tscn, vn_portrait.tscn, etc. |
| PlayerController + Exploration scene | TODO | — | Movement system |
| BattleManager + Battle scene | TODO | — | Turn-based combat |
| InventoryManager + UI | TODO | — | Item management |
| QuestManager + Quest log | TODO | — | Quest lifecycle |
| Create sample database resources | TODO | — | Items, enemies, characters |
| Save/Load integration | TODO | — | Connect UI to SaveManager |
| Settings screen | TODO | — | Audio, input, display settings |

---

## In Progress

| Task | Started | Progress | Notes |
|------|---------|----------|-------|
| — | — | — | — |

---

## Completed

| Task | Completed | Notes |
|------|-----------|-------|
| Documentation system | 2026-06-28 | All core docs created |
| Visual Novel Framework | 2026-06-30 | 37 files: commands, compiler, manager, UI, docs |
| World Navigation System | 2026-07-01 | 21 files: NavigationManager, WorldMap, RegionHub, BuildingInterior, data structures, docs |

---

## Known Blockers

| Issue | Affects | Status |
|-------|---------|--------|
| — | — | — |

---

## VN Framework Files (37 total)

**Core (25 files):** `scripts/core/vn/` — `vn_command.gd`, `vn_dialogue_resource.gd`, `vn_choice_data.gd`, `vn_script_compiler.gd`, 20 command classes in `vn_commands/`

**Managers (7 files):** `scripts/managers/vn/` — `vn_manager.gd`, `vn_state_machine.gd`, `vn_command_executor.gd`, `vn_variable_store.gd`, `vn_typewriter.gd`, `vn_auto_skip.gd`, `vn_history.gd`

**UI (2 files):** `scripts/ui/vn/` — `vn_panel.gd`, `vn_portrait.gd`

**Data (1 file):** `database/dialogue/sample_prologue.dialogue`

**Docs (3 files):** `docs/vn_framework.md`, `docs/vn_script_format.md`, `docs/vn_commands.md`

---

## Template for New Tasks

```markdown
### Task: [Name]

**Description**: Brief description of what needs to be done.
**Dependencies**: List of prerequisite tasks or issues.
**Acceptance Criteria**:
- [ ] Criterion 1
- [ ] Criterion 2
**Estimated Effort**: X hours/days
**Assignee**: —
```

---

## Related

- [roadmap.md](roadmap.md) — Long-term milestones
- [technical_debt.md](technical_debt.md) — Known issues
- [decisions.md](decisions.md) — Design decisions