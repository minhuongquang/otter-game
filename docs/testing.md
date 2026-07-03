# Testing

> **Purpose**: Define testing strategy, validation procedures, and quality assurance.  
> **Scope**: Unit tests, integration tests, manual testing, test scenes.  
> **Status**: Draft — to be refined as testing infrastructure is built.

---

## Testing Philosophy

- Every feature must have a validation plan.
- No code is considered working until tested.
- Automated tests run before every commit.
- Manual testing covers visual and gameplay validation.

---

## Test Types

| Type | Tool | Coverage | Run Frequency |
|------|------|----------|---------------|
| Unit Tests | GDScript tests | Functions, calculations | Every commit |
| Integration Tests | GDScript test scenes | Module interactions | Daily |
| Visual Tests | Manual | UI, scenes, animations | Per feature |
| Gameplay Tests | Manual | Full game flow | Per milestone |
| Regression Tests | Automated + Manual | Previously fixed bugs | Per release |

---

## Unit Tests

Test individual functions in isolation.

```gdscript
# tests/test_damage_calculator.gd
func test_physical_damage() -> void:
    var attacker = BattleActor.new()
    attacker.set_stat("ATK", 100)
    var defender = BattleActor.new()
    defender.set_stat("DEF", 50)
    var damage = DamageCalculator.calculate(attacker, defender, SkillResource.new())
    assert(damage > 0)
    assert(damage < 200)
```

### Test File Organization

```
tests/
├── test_battle/
│   ├── test_damage_calculator.gd
│   ├── test_enemy_ai.gd
│   └── test_status_effects.gd
├── test_dialogue/
│   ├── test_dialogue_conditions.gd
│   └── test_dialogue_branching.gd
├── test_inventory/
│   ├── test_item_management.gd
│   └── test_equipment.gd
└── test_quest/
    ├── test_quest_lifecycle.gd
    └── test_quest_conditions.gd
```

---

## Integration Tests

Test module interactions through events.

```gdscript
# tests/test_battle_quest_integration.gd
func test_battle_victory_triggers_quest() -> void:
    # Start a quest
    QuestManager.start_quest("test_quest")
    # Simulate a battle victory
    BattleManager.emit_signal("battle_victory", {"enemy_group": "test_group"})
    # Verify quest advanced
    var state = QuestManager.get_quest_state("test_quest")
    assert(state == QuestState.IN_PROGRESS)
```

---

## Test Scenes

Create isolated test scenes for visual validation.

```
tests/
├── test_scenes/
│   ├── test_dialogue_box.tscn    — Test dialogue rendering
│   ├── test_battle_ui.tscn       — Test battle menu layout
│   ├── test_inventory_grid.tscn   — Test inventory scrolling
│   └── test_exploration.tscn     — Test player movement
```

---

## Manual Test Checklist

### Before Each Feature Commit

- [ ] No syntax errors in new/modified scripts.
- [ ] Existing scenes open without errors.
- [ ] New feature works in editor play mode.
- [ ] No broken references (scenes, resources, signals).
- [ ] Console has no errors or warnings.

### Before Milestone Build

- [ ] Main menu loads without errors.
- [ ] New game starts correctly.
- [ ] Visual Novel system works (advance, choices, skip).
- [ ] World map navigation works.
- [ ] Exploration movement and collision work.
- [ ] Battle system works (commands, turns, victory, defeat).
- [ ] Items can be collected and used.
- [ ] Quests can be started and completed.
- [ ] Save and load works across scenes.
- [ ] Settings persist between sessions.
- [ ] Audio plays correctly (BGM, SFX).
- [ ] Controller input works (if implemented).

### Before Release

- [ ] Full playthrough without crashes.
- [ ] All dialogue choices resolve correctly.
- [ ] All quests are completable.
- [ ] No game-breaking bugs.
- [ ] Save/load is reliable.
- [ ] Performance is acceptable (60 FPS target).
- [ ] No memory leaks on scene transitions.
- [ ] Localization (if implemented) is complete.

---

## Bug Reporting

### Template

```
## Bug Report

**Description**: [Brief description]

**Steps to Reproduce**:
1. Go to [scene/screen]
2. Do [action]
3. Observe [unexpected behavior]

**Expected**: [What should happen]

**Actual**: [What actually happens]

**Environment**:
- Build version: [version]
- OS: [Windows/macOS/Linux]
- Controller: [Keyboard/Controller type]
```

---

## Related

- [coding_guidelines.md](coding_guidelines.md) — Code quality
- [current_tasks.md](current_tasks.md) — Known issues
- [technical_debt.md](technical_debt.md) — Technical debt tracking
- [release_checklist.md](release_checklist.md) — Release process
