# Battle System

> **Status**: M5.0 (Foundation) + M5.1 (Headless Simulation) complete. UI pending (M5.2).

## Overview

Turn-based combat, party vs. enemies. One actor per side in M5.0 (multi-actor in M6). Actions submitted by player/AI, resolved through `DamageCalculator`, results delivered as `BattleResult`. Flow controlled by `BattleStateMachine`.

## Files

| File | Class | Role |
|------|-------|------|
| `scripts/battle/battle_enums.gd` | `BattleEnums` | `CommandType`, `Team`, `Element`, `BattleOutcome` |
| `scripts/battle/battle_state_machine.gd` | `BattleStateMachine` | State tracking + transition validation |
| `scripts/battle/status_effect.gd` | `StatusEffect` | Status, buff, debuff data |
| `scripts/battle/battle_actor.gd` | `BattleActor` + `StatModifier` | Live combat participant |
| `scripts/core/battle_command.gd` | `BattleCommand` | Pending action |
| `scripts/core/battle_result.gd` | `BattleResult` + `TargetResult` | Action outcomes |
| `scripts/utilities/damage_calculator.gd` | `DamageCalculator` + `DamageCalcResult` | Stateless formulas |
| `scripts/battle/turn_manager.gd` | `TurnManager` | Round-robin turn order |
| `scripts/battle/battle_factory.gd` | `BattleFactory` | Resource → BattleActor conversion |
| `scripts/battle/enemy_ai.gd` | `EnemyAI` | Phase 1: basic attack random |
| `scripts/battle/battle_manager.gd` | `BattleManager` | Full battle orchestrator |
| `scenes/battle/battle.tscn` | (scene) | Root Node, owns BattleManager |

## States

```
IDLE → INITIALIZING → PLAYER_TURN → EXECUTING_ACTION → CHECK_RESULT
                          ↑              ↑                  │
                          │              │                  ├→ VICTORY → CLEANUP → FINISHED
                          └─ ENEMY_TURN ─┘                  │
                                                            └→ DEFEAT  → CLEANUP → FINISHED
```

### State Descriptions

| State | Meaning |
|-------|---------|
| `IDLE` | No battle active |
| `INITIALIZING` | Setting up actors |
| `PLAYER_TURN` | Waiting for player command |
| `ENEMY_TURN` | AI selecting action |
| `EXECUTING_ACTION` | Command being resolved (blocking) |
| `CHECK_RESULT` | Evaluate after action: next actor / victory / defeat |
| `VICTORY` | All enemies defeated |
| `DEFEAT` | All party defeated |
| `CLEANUP` | Post-battle processing |
| `FINISHED` | Terminal |

## Transitions

| From | To | Trigger |
|------|----|---------|
| `IDLE` | `INITIALIZING` | `start_battle()` |
| `INITIALIZING` | `PLAYER_TURN` | First actor is player |
| `INITIALIZING` | `ENEMY_TURN` | First actor is enemy |
| `PLAYER_TURN` | `EXECUTING_ACTION` | Player confirmed command |
| `PLAYER_TURN` | `CHECK_RESULT` | Player chose Flee (skip execution) |
| `ENEMY_TURN` | `EXECUTING_ACTION` | AI selected command |
| `EXECUTING_ACTION` | `CHECK_RESULT` | Command resolved |
| `CHECK_RESULT` | `PLAYER_TURN` | Next actor is player |
| `CHECK_RESULT` | `ENEMY_TURN` | Next actor is enemy |
| `CHECK_RESULT` | `VICTORY` | All enemies `is_defeated()` |
| `CHECK_RESULT` | `DEFEAT` | All party `is_defeated()` |
| `VICTORY` | `CLEANUP` | Rewards processed |
| `DEFEAT` | `CLEANUP` | Game-over flow triggered |
| `CLEANUP` | `FINISHED` | Scene transition initiated |

Invalid transitions → `push_error()` + `false`.

## Turn Loop (M5.0)

Single actor per side. No turn order queue needed.

1. `INITIALIZING` — BattleManager creates `BattleActor` instances.
2. `PLAYER_TURN` — UI shows CommandMenu. Player picks Attack/Guard/Flee.
3. `EXECUTING_ACTION` — BattleManager calls `DamageCalculator`, applies results via `BattleActor.take_damage()`, records `BattleResult`.
4. `CHECK_RESULT` — If enemy defeated → `VICTORY`. If player defeated → `DEFEAT`. Otherwise → back to `PLAYER_TURN`.

Enemy turn flows identically: `ENEMY_TURN` → `EXECUTING_ACTION` → `CHECK_RESULT` → back to `PLAYER_TURN`.

## Signals

### BattleStateMachine

| Signal | Payload | When |
|--------|---------|------|
| `state_changed` | `old_state: State, new_state: State` | Every successful `transition_to()` |
| `battle_finished` | `outcome: BattleEnums.BattleOutcome` | Entering `VICTORY` or `DEFEAT` (exactly once) |

### BattleEnums.BattleOutcome

```gdscript
enum BattleOutcome { VICTORY, DEFEAT, FLEE, ABORTED }
```

| Value | Meaning |
|-------|---------|
| `VICTORY` | All enemies defeated |
| `DEFEAT` | All party defeated |
| `FLEE` | Player escaped successfully |
| `ABORTED` | Battle forcibly ended (scene change, system interruption) |

`FLEE` is handled by `PLAYER_TURN → CHECK_RESULT` (skips `EXECUTING_ACTION`). BattleManager evaluates flee chance in `CHECK_RESULT` and emits `battle_finished(FLEE)` before `CLEANUP`.

## Battle Start Flow

1. Encounter trigger → `SceneManager.change_scene("battle")` with `pending_data` containing `enemy_group_id`.
2. Battle scene `_ready()` → BattleManager `start_battle(enemy_group_id)`.
3. BattleManager loads `EnemyResource` via Database, creates `BattleActor` array.
4. BattleManager creates party `BattleActor` from current party state.
5. BattleManager calls `state_machine.transition_to(INITIALIZING)`.
6. `state_changed` signal → BattleManager populates actors, determines first turn.
7. BattleManager calls `state_machine.transition_to(PLAYER_TURN)` or `ENEMY_TURN`.

## End Flow

1. `state_machine` enters `VICTORY` or `DEFEAT` → emits `battle_finished(outcome)`.
2. BattleManager receives signal, triggers rewards (victory) or game-over (defeat).
3. BattleManager calls `transition_to(CLEANUP)`.
4. `CLEANUP` → `FINISHED` triggers `SceneManager.change_scene()` back to exploration or game-over screen.

## Abort / Scene Change Safety

`ABORTED` covers:

- `SceneManager.change_scene()` called mid-battle.
- Player forcibly exits via menu during battle.
- System event requires battle cancellation.

Procedure:

1. BattleManager receives abort trigger.
2. BattleManager emits `battle_finished(ABORTED)`.
3. BattleManager calls `transition_to(CLEANUP)` → `transition_to(FINISHED)`.
4. Scene transition proceeds normally. Battle state is discarded.

Battle is never resumed after `FINISHED`. No partial state persists.

## Damage Calculation

Formula (physical): `power * (1.0 + atk * 0.01) / (1.0 + def * 0.01) * variance(0.9–1.1) * element_mult * critical(1.5) * guard(0.5)`

Formula (magical): Same, using `magic_attack` and `magic_defense`.

Formula (healing): `power * (1.0 + caster.magic_attack * 0.01)`, minimum 1.

Element table: 2.0 weak, 1.0 neutral, 0.5 resist. 9 elements including NEUTRAL.

Miss: `hit_chance = agi / (agi + defender_agi)`, clamped 5%–95%.

Critical: `luck / 10 / 100` chance, 1.01%–50%, 1.5x multiplier.

`DamageCalcResult` is a typed return (`final_damage: int, is_critical: bool, is_missed: bool, element_multiplier: float, was_guarded: bool`).

## Key Architecture Rules

- `BattleStateMachine` is RefCounted. No Node inheritance. No scene access. No gameplay logic.
- `DamageCalculator` is stateless. All methods static. No scene dependencies.
- `BattleActor` exposes computed stat getters (`get_attack()`, etc.). Base stats from `StatsResource`. Modifiers from `Dictionary[StringName, Array[StatModifier]]`.
- `BattleResult` uses per-target `TargetResult` for multi-target support.
- `BattleCommand` uses `item_id: StringName` placeholder (resolved when inventory system exists, M7).
- `StatusEffect` is its own file. Supports simultaneous effects via `Array[StatusEffect]` on `BattleActor`. Types include ailments, buffs, debuffs, regen, shield.

## Related

- [roadmap.md](roadmap.md)
- [current_tasks.md](current_tasks.md)
- [game_design.md](game_design.md)
- [event_system.md](event_system.md)