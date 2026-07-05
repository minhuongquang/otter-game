# Current Tasks

> **Purpose**: Track active development tasks, priorities, and assignees.  
> **Type**: Living document — update as tasks change.  
> **Last Updated**: 2026-07-05 (M5.0.1–M5.0.4 complete)

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

## Milestone M4 Complete ✅

All navigation wiring validated:
- 11 `SceneManager.change_scene()` calls — 0 direct `get_tree().change_scene_to_file()` calls
- Pending data consumed exactly once per transition
- No stale transition data remains
- Player input restored after every transition

## Remaining Technical Debt

- `world_map.gd` back button transitions to MainMenu — acceptable for now (not main flow path)
- `go_back()` stub in SceneManager — not wired; no scene history tracking exists
- `TestInteractable.print("Interaction successful.")` — intentional demo behavior from M3.1

---

## Active Milestone: M5 — "Fight" (Battle Foundation)

**Architecture review complete** (2026-07-05). M5 split into 4 sub-milestones ordered by dependency.

### M5.0 — Foundation

| # | Task | Status | Files to Create |
|---|------|--------|-----------------|
| 5.0.1 | Create `BattleCommand` (RefCounted) | ✅ DONE | `scripts/core/battle_command.gd` |
| 5.0.2 | Create `BattleResult` (RefCounted) | ✅ DONE | `scripts/core/battle_result.gd` |
| 5.0.3 | Create `BattleActor` | ✅ DONE | `scripts/battle/battle_actor.gd` |
| 5.0.4 | Create `DamageCalculator` utility | ✅ DONE | `scripts/utilities/damage_calculator.gd` |
| 5.0.4a | Create shared `BattleEnums` | ✅ DONE | `scripts/battle/battle_enums.gd` |
| 5.0.4b | Create `StatusEffect` | ✅ DONE | `scripts/battle/status_effect.gd` |
| 5.0.5 | Create `BattleStateMachine` | ✅ DONE | `scripts/battle/battle_state_machine.gd` |
| 5.0.6 | Create `TurnManager` | ⬜ TODO | `scripts/battle/turn_manager.gd` |
| 5.0.7 | Create sample .tres files | ⬜ TODO | `database/enemies/slime_stats.tres`, `database/skills/basic_attack.tres`, `database/enemies/slime.tres`, `database/characters/hero.tres` |
| 5.0.8 | Write DamageCalculator unit test | ⬜ TODO | `tests/test_battle/test_damage_calculator.gd` |

### M5.1 — Battle Simulation (headless)

| # | Task | Status | Files to Create |
|---|------|--------|-----------------|
| 5.1.1 | Create Battle scene root | ⬜ TODO | `scenes/battle/battle.tscn` |
| 5.1.2 | Implement BattleManager orchestrator | ⬜ TODO | `scripts/battle/battle_manager.gd` |
| 5.1.3 | Implement basic enemy AI | ⬜ TODO | `scripts/battle/enemy_ai.gd` |
| 5.1.4 | Create manual encounter trigger (B key) | ⬜ TODO | — |
| 5.1.5 | Implement victory/defeat + BattleResult emission | ⬜ TODO | — |
| 5.1.6 | Wire EventBus emissions | ⬜ TODO | — |
| 5.1.7 | Headless validation via console | ⬜ TODO | — |

### M5.2 — Battle UI

| # | Task | Status | Files to Create |
|---|------|--------|-----------------|
| 5.2.1 | Create stat bar component (reusable) | ⬜ TODO | `scenes/ui/stat_bar.tscn` |
| 5.2.2 | Create PartyPanel | ⬜ TODO | `scenes/battle/party_panel.tscn` |
| 5.2.3 | Create EnemyPanel | ⬜ TODO | `scenes/battle/enemy_panel.tscn` |
| 5.2.4 | Create CommandMenu (Attack only) | ⬜ TODO | `scenes/battle/command_menu.tscn` |
| 5.2.5 | Create BattleLog | ⬜ TODO | `scenes/battle/battle_log.tscn` |
| 5.2.6 | Create BattleUIController | ⬜ TODO | `scripts/battle/battle_ui_controller.gd` |

### M5.3 — Party Save State

| # | Task | Status | Notes |
|---|------|--------|-------|
| 5.3.1 | Expand SaveManager._collect_save_data() | ⬜ TODO | Read actual party HP/SP/level |
| 5.3.2 | Expand SaveManager._apply_save_data() | ⬜ TODO | Restore party state on load |
| 5.3.3 | Wire autosave on battle victory | ⬜ TODO | — |
| 5.3.4 | Manual save/load cycle test | ⬜ TODO | — |

### M6: "Fight Smarter" — Full Command Set

| # | Task | Status | Notes |
|---|------|--------|-------|
| 6.0 | AGI Turn Order + Multi-Actor | ⬜ TODO | Upgrade TurnManager, second party member + enemy |
| 6.1 | Skill + Guard + Flee commands | ⬜ TODO | SP cost, skill menu, guard flag, flee chance |
| 6.2 | Item command | 🔀 DEFERRED | Requires InventoryManager from M7 |
| 6.3 | Expanded damage calc | ⬜ TODO | Elements, crits, variance, guard reduction |
| 6.4 | Status effects + advanced AI | ⬜ TODO | Poison/sleep/burn, aggressive AI type |

### M7: "Loot" — Inventory + Rewards

| # | Task | Status | Files to Create |
|---|------|--------|-----------------|
| 7.1 | Implement `inventory_manager.gd` | ⬜ TODO | `scripts/managers/inventory_manager.gd` |
| 7.2 | Create inventory + item slot scenes | ⬜ TODO | 2 .tscn files |
| 7.3 | Wire victory rewards → inventory | ⬜ TODO | — |
| 7.4 | Wire item usage (inventory screen + battle item command) | ⬜ TODO | Includes M6.2 Item command |
| 7.5 | Create 5 sample items | ⬜ TODO | 5 .tres files |

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
| D1 — Main Menu Functionality | 2026-07-04 | New Game (reset flags + VN transition), Load (placeholder), Settings (BGM/SFX sliders + display mode), Quit (editor-safe), Test Room (sandbox with player movement) |
| M5/M6 Architecture Review | 2026-07-05 | M5 split into 4 sub-milestones. M6 split into 4+1 (Item deferred to M7). 7 foundation classes planned, 3 components introduced (StateMachine, TurnManager, DamageCalculator) |
| M5.0.1–M5.0.4 Battle Foundation | 2026-07-05 | 6 files created: BattleCommand, BattleResult, BattleActor, DamageCalculator, BattleEnums, StatusEffect. Typed with DamageCalcResult, TargetResult, StatModifier. Extensible array-based status, enum elements, computed stat getters. |
| M5.0.5 BattleStateMachine | 2026-07-05 | RefCounted state machine with 10 states, 14 transitions, 2 signals. Includes BattleOutcome enum added to battle_enums.gd. No gameplay logic, no scene deps. |

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