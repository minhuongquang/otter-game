# Release Checklist

> **Purpose**: Define the pre-release verification process for builds.  
> **Type**: Living document — update as release requirements evolve.  
> **Last Updated**: 2026-06-28

---

## How to Use

- Run through this checklist before every release build.
- Mark each item as PASS or FAIL.
- If an item fails, fix it before proceeding.
- Add new items as release requirements are identified.

---

## Pre-Release Checklist

### Build Verification

- [ ] Project builds without errors.
- [ ] All `.tscn` files load without errors.
- [ ] All `.tres` resources load without errors.
- [ ] No missing asset references.
- [ ] No orphaned nodes on scene transitions.
- [ ] Build size is within expected range.

### Main Menu

- [ ] Main menu loads correctly.
- [ ] New Game starts correctly.
- [ ] Load Game shows available slots.
- [ ] Settings screen opens and functions.
- [ ] Credits screen displays correctly.
- [ ] Quit game works.

### Visual Novel

- [ ] Dialogue displays correctly (text, portraits, background).
- [ ] Auto-advance works.
- [ ] Skip works.
- [ ] Choices display and resolve correctly.
- [ ] Dialogue log works.
- [ ] VN transitions to gameplay correctly.

### World Map

- [ ] World map displays correctly.
- [ ] Location icons are clickable.
- [ ] Locked locations show lock state.
- [ ] Map transitions work correctly.

### Exploration

- [ ] Player movement is smooth.
- [ ] Collision works correctly.
- [ ] NPC interaction triggers dialogue.
- [ ] Chests grant items.
- [ ] Doors/portals transition correctly.
- [ ] Random encounters trigger.
- [ ] Map boundaries are correct.

### Battle

- [ ] Battle starts correctly.
- [ ] Turn order is correct.
- [ ] All commands work (Attack, Skill, Guard, Item, Flee).
- [ ] Damage calculation is correct.
- [ ] Status effects apply and expire.
- [ ] Victory screen shows rewards.
- [ ] Defeat screen shows options.
- [ ] Escape works correctly.

### Inventory

- [ ] Item list displays correctly.
- [ ] Item categories work.
- [ ] Item detail shows correct info.
- [ ] Use item works.
- [ ] Equip/Unequip works.
- [ ] Currency display updates.

### Quests

- [ ] Quest list shows active quests.
- [ ] Quest detail shows objectives.
- [ ] Quest progress updates correctly.
- [ ] Quest completion grants rewards.

### Save/Load

- [ ] Save works in all scenes.
- [ ] Load restores correct state.
- [ ] Autosave triggers correctly.
- [ ] Quick save/load works.
- [ ] Save slots display correctly.
- [ ] Delete save works.

### Settings

- [ ] Volume sliders work.
- [ ] Fullscreen/windowed toggle works.
- [ ] Resolution options work.
- [ ] Key rebinding works.
- [ ] Settings persist between sessions.

### Audio

- [ ] BGM plays in all scenes.
- [ ] SFX plays for interactions.
- [ ] Volume control works.
- [ ] Audio doesn't stutter or skip.
- [ ] BGM transitions are smooth.

### Performance

- [ ] 60 FPS in exploration (empty scene).
- [ ] 60 FPS in battle (6 enemies + 4 party).
- [ ] 60 FPS in VN mode.
- [ ] Scene transitions take < 2 seconds.
- [ ] Memory usage stable over 30 minutes.
- [ ] No memory leaks on repeated scene transitions.

### Error Handling

- [ ] Missing save file shows graceful error.
- [ ] Missing resource shows graceful error.
- [ ] Invalid save version shows migration prompt.
- [ ] No unhandled exceptions.
- [ ] Controller disconnection shows warning.

---

## Release Template

```markdown
## Release v[VERSION]

**Date**: YYYY-MM-DD
**Build**: [Build ID / Commit Hash]

### Checklist Results
- Build Verification: PASS / FAIL
- Main Menu: PASS / FAIL
- Visual Novel: PASS / FAIL
- World Map: PASS / FAIL
- Exploration: PASS / FAIL
- Battle: PASS / FAIL
- Inventory: PASS / FAIL
- Quests: PASS / FAIL
- Save/Load: PASS / FAIL
- Settings: PASS / FAIL
- Audio: PASS / FAIL
- Performance: PASS / FAIL
- Error Handling: PASS / FAIL

### Known Issues
- [List any known issues in this release]

### Notes
- [Any additional notes about this release]
```

---

## Related

- [roadmap.md](roadmap.md) — Release milestones
- [testing.md](testing.md) — Testing procedures
- [current_tasks.md](current_tasks.md) — Active tasks
