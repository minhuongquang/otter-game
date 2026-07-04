# Current Tasks

> **Purpose**: Track active development tasks, priorities, and assignees.  
> **Type**: Living document — update as tasks change.  
> **Last Updated**: 2026-07-03

---

## How to Use

- Add new tasks under the appropriate category.
- Mark tasks as [DONE] when complete.
- Move completed tasks to the "Completed" section.
- Update weekly.

---

## Phase 2 Overview

Phase 2 delivers ONE fully playable region demonstrating every core gameplay loop.

**11 milestones**, each ending with a playable improvement.  
Each milestone is ~2-3 days of work.

See [phase2_roadmap.md](phase2_roadmap.md) for full details.

---

## Active Milestone: M3.5 — "Sample NPC Content"

**Goal**: Create sample content for testing the interaction and dialogue pipeline.

**Playable result**: Walk → press E near NPC A → greeting dialogue → walk to NPC B → multi-line dialogue

| # | Task | Status | Files to Create/Modify |
|---|------|--------|-----------------|
| 3.5.1 | Create Dialogue A (simple greeting) | ✅ DONE | `database/dialogue/npc_a_greeting.dialogue` |
| 3.5.2 | Create Dialogue B (multi-line conversation) | ✅ DONE | `database/dialogue/npc_b_conversation.dialogue` |
| 3.5.3 | Add compile-on-demand fallback to NPC.gd | ✅ DONE | `scripts/components/npc.gd` |
| 3.5.4 | Place both NPCs in placeholder map with unique dialogue_ids | ✅ DONE | `scenes/exploration/placeholder_map.tscn` |

---

## Milestone M3 Complete ✅

All sub-milestones for M3 ("Talk") are done. The player can now walk up to an NPC and interact with dialogue.

## Upcoming Milestones

### M4: "World Flow" — Navigation Integration

| # | Task | Status | Notes |
|---|------|--------|-------|
| 4.1 | Wire VN end → WorldMap | ⬜ TODO | Wiring only |
| 4.2 | Wire region selection → RegionHub | ⬜ TODO | Wiring only |
| 4.3 | Wire building selection → BuildingInterior | ⬜ TODO | Wiring only |
| 4.4 | Wire BuildingInterior → exploration map | ⬜ TODO | Wiring only |
| 4.5 | Wire Exploration exit → RegionHub | ⬜ TODO | Wiring only |
| 4.6 | Implement SceneManager pending data pattern | ⬜ TODO | — |

### M5: "Fight" — Battle Foundation

| # | Task | Status | Files to Create |
|---|------|--------|-----------------|
| 5.1 | Implement `battle_manager.gd` | ⬜ TODO | `scripts/managers/battle_manager.gd` |
| 5.2 | Implement `battle_actor.gd` | ⬜ TODO | `scripts/utilities/battle_actor.gd` |
| 5.3 | Create 4 battle scenes | ⬜ TODO | 5 .tscn files |
| 5.4 | Create manual encounter trigger | ⬜ TODO | — |
| 5.5 | Create 2 enemies + 1 group + 1 skill | ⬜ TODO | 4 .tres files |

### M6: "Fight Smarter" — Full Command Set

| # | Task | Status | Notes |
|---|------|--------|-------|
| 6.1 | Add Skill, Item, Guard, Flee commands | ⬜ TODO | Extends battle manager |
| 6.2 | Expand damage calc (elements, crits, status) | ⬜ TODO | — |
| 6.3 | Create 3 more skills | ⬜ TODO | 3 .tres files |

### M7: "Loot" — Inventory + Rewards

| # | Task | Status | Files to Create |
|---|------|--------|-----------------|
| 7.1 | Implement `inventory_manager.gd` | ⬜ TODO | `scripts/managers/inventory_manager.gd` |
| 7.2 | Create inventory + item slot scenes | ⬜ TODO | 2 .tscn files |
| 7.3 | Wire victory rewards → inventory | ⬜ TODO | — |
| 7.4 | Create 5 sample items | ⬜ TODO | 5 .tres files |

### M8: "Goal" — Quest System

| # | Task | Status | Files to Create |
|---|------|--------|-----------------|
| 8.1 | Implement `quest_manager.gd` | ⬜ TODO | `scripts/managers/quest_manager.gd` |
| 8.2 | Create `quest_log.tscn` | ⬜ TODO | `scenes/ui/quest_log.tscn` |
| 8.3 | Wire quest events (dialogue, battle, collect, talk) | ⬜ TODO | — |
| 8.4 | Create 2 sample quests | ⬜ TODO | 2 .tres files |

### M9: "Remember" — Save/Load

| # | Task | Status | Files to Create |
|---|------|--------|-----------------|
| 9.1 | Create `save_screen.tscn` | ⬜ TODO | `scenes/ui/save_screen.tscn` |
| 9.2 | Wire SaveManager to save screen | ⬜ TODO | — |
| 9.3 | Verify all system serialization | ⬜ TODO | — |

### M10: "Content" — Fill the Region

| # | Task | Status | Notes |
|---|------|--------|-------|
| 10.1 | Create full exploration map | ⬜ TODO | `verdant_forest.tscn` |
| 10.2 | Expand prologue dialogue | ⬜ TODO | 50+ lines |
| 10.3 | Town NPC dialogue | ⬜ TODO | 3+ files |
| 10.4 | 3 more enemies, 5 more items, 1 more quest | ⬜ TODO | .tres files |
| 10.5 | Add random encounters | ⬜ TODO | — |

### M11: "Polish" — Edge Cases + Cleanup

| # | Task | Status | Notes |
|---|------|--------|-------|
| 11.1 | Settings screen (audio) | ⬜ TODO | `settings_screen.tscn` |
| 11.2 | VN history + quick menu (if deferred) | ⬜ TODO | 2 .tscn files |
| 11.3 | Edge case fixes | ⬜ TODO | Various |
| 11.4 | Update documentation | ⬜ TODO | — |

---

## Completed

| Task | Completed | Notes |
|------|-----------|-------|
| Documentation system | 2026-06-28 | All core docs created |
| Project setup (Godot 4.x) | 2026-06-28 | project.godot, imports, 7 autoloads |
| Folder structure | 2026-06-28 | assets/, scripts/, scenes/, database/ |
| Core autoloads | 2026-06-28 | EventBus, Database, Save, Audio, Input, UI, Scene |
| Boot + Main Menu scene | 2026-06-28 | Splash, main menu, transitions |
| Core resource definitions | 2026-06-28 | 9 resource classes |
| Visual Novel Framework | 2026-06-30 | 37 files: commands, compiler, manager, UI, docs |
| World Navigation System | 2026-07-01 | 21 files: NavigationManager, WorldMap, RegionHub, BuildingInterior, data structures, docs |
| Sample world data | 2026-07-01 | 2 regions, 4 buildings, 1 shop, 2 region connections |
| Phase 2 Roadmap | 2026-07-03 | 11-milestone plan in [phase2_roadmap.md](phase2_roadmap.md) |
| M1 — "Boot to VN" | 2026-07-03 | 4 VN scenes, boot → main menu → VN flow |
| M2 — "Walk" (Player Movement) | 2026-07-03 | player.tscn, player_controller.gd, placeholder_map.tscn, hero.tres, InputManager wiring |

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

## Related

- [roadmap.md](roadmap.md) — Long-term milestones
- [phase2_roadmap.md](phase2_roadmap.md) — Detailed Phase 2 implementation plan
- [technical_debt.md](technical_debt.md) — Known issues