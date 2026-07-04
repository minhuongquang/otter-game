# Phase 2 Roadmap — Detailed Implementation Plan

> **Purpose**: Detailed implementation plan for Phase 2 (Prototype).  
> **Type**: Living document — update as milestones are completed.  
> **Last Updated**: 2026-07-03

---

## Overview

Phase 2 delivers ONE fully playable region demonstrating every core gameplay loop.

**Target flow**:

```
Boot → Main Menu → Prologue VN → World Map → Region Hub → Building → Exploration
→ NPC → Dialogue → Quest → Battle → Loot → Inventory → Return NPC → Quest Complete
→ Save → Quit → Load → Continue
```

**Design principles**:

- **Vertical slice first**: Complete gameplay loops over isolated systems
- **Incremental save**: Each system becomes saveable immediately after implementation
- **Sample data alongside systems**: Never build a system without test content
- **Small milestones**: Each milestone is ~2-3 days of work, ends with a playable build
- **AI agent friendly**: Each milestone touches a limited number of files

---

## Milestone 1: "Boot to VN" — Visual Novel Playable

**Goal**: Player boots the game, sees main menu, watches the prologue VN with text and choices.

**Why now**: Entry point to all content. No gameplay can be tested without it.

**Complexity**: Low

**Playable result**: Boot → Main Menu → Prologue VN (text, portraits, choices)

### Tasks

| # | Task | Files to Create | Files to Modify |
|---|------|----------------|-----------------|
| 1.1 | Create `visual_novel.tscn` — root VN scene | `scenes/ui/vn/visual_novel.tscn` | — |
| 1.2 | Create `vn_dialogue_box.tscn` — text display, name label, continue indicator | `scenes/ui/vn/vn_dialogue_box.tscn` | — |
| 1.3 | Create `vn_portrait.tscn` — portrait container with side support | `scenes/ui/vn/vn_portrait.tscn` | — |
| 1.4 | Create `vn_choice_menu.tscn` — choice button list | `scenes/ui/vn/vn_choice_menu.tscn` | — |
| 1.5 | Wire Boot → Main Menu → VN → sample_prologue.dialogue | — | `scenes/world/boot.tscn`, `scenes/ui/main_menu.tscn` |
| 1.6 | Test full prologue playthrough | — | — |

### Dependencies

- VNManager (exists)
- VN scripts (37 files exist)
- Boot scene (exists)
- MainMenu scene (exists)
- sample_prologue.dialogue (exists)

### Save Integration

None yet — no game state to save.

### Sample Data

Already exists: `database/dialogue/sample_prologue.dialogue`

### Validation

- [ ] Game boots to main menu
- [ ] New Game starts prologue VN
- [ ] Text displays correctly with typewriter effect
- [ ] Portraits appear on correct sides
- [ ] Choices appear and are selectable
- [ ] VN completes without errors

---

## Milestone 2: "Walk" — Player Movement

**Goal**: Player can move a character in a 2D space with camera following.

**Why now**: Movement is the primary interaction mode. Everything else builds on it.

**Complexity**: Low

**Playable result**: Walk around a simple map with camera following

### Tasks

| # | Task | Files to Create | Files to Modify |
|---|------|----------------|-----------------|
| 2.1 | Create `player.tscn` — CharacterBody2D + CollisionShape2D + AnimatedSprite2D + Camera2D | `scenes/characters/player.tscn` | — |
| 2.2 | Implement `player_controller.gd` — movement, acceleration, friction, direction, collision | `scripts/world/player_controller.gd` | — |
| 2.3 | Create `placeholder_map.tscn` — simple ground tilemap + wall borders | `scenes/exploration/placeholder_map.tscn` | — |
| 2.4 | Wire player input to InputManager context | — | `scripts/world/player_controller.gd` |
| 2.5 | Create 1 sample character resource for the hero | `database/characters/hero.tres` | — |

### Dependencies

- InputManager (exists)
- Milestone 1 (for scene flow)

### Save Integration

Add `player_data` to SaveManager:

```gdscript
# In SaveManager
func get_player_data() -> Dictionary:
    return {
        "position": [player.position.x, player.position.y],
        "map_id": current_map_id,
        "facing": player.facing_direction
    }
```

### Sample Data

- 1 character resource: `database/characters/hero.tres`

### Validation

- [ ] Player moves with WASD/arrow keys
- [ ] Movement has acceleration and deceleration
- [ ] Player faces the direction of movement
- [ ] Camera follows player smoothly
- [ ] Collision stops player at walls
- [ ] Player cannot walk outside map bounds

---

## Milestone 3: "Talk" — NPC Interaction → VN

**Goal**: Player walks up to an NPC, presses interact, VN dialogue opens.

**Why now**: Bridges exploration to content. NPCs are how players receive quests, story, and shop access.

**Complexity**: Low

**Playable result**: Walk → see NPC → press E → VN dialogue → choices → close

### Status

M3.1 (Interaction Foundation) is complete. M3.2–3.5 (NPC Integration) is deferred.

### Sub-milestone 3.1: Interaction Foundation ✅ DONE

| # | Task | Files to Create | Files to Modify |
|---|------|----------------|-----------------|
| 3.1.1 | Create `interactable.gd` — base class (Area2D, prompt, one_time, can_interact, interact) | `scripts/components/interactable.gd` | — |
| 3.1.2 | Create `test_interactable.gd` — demo (console print) | `scripts/components/test_interactable.gd` | — |
| 3.1.3 | Create `test_interactable.tscn` — scene with collision shape | `scenes/characters/test_interactable.tscn` | — |
| 3.1.4 | Add interaction detection + input to PlayerController | — | `scripts/world/player_controller.gd` |
| 3.1.5 | Instance test interactable in placeholder map | — | `scenes/exploration/placeholder_map.tscn` |

### Sub-milestone 3.2–3.5: NPC Integration (Deferred)

| # | Task | Files to Create | Files to Modify |
|---|------|----------------|-----------------|
| 3.2 | Create `npc.gd` — extends Interactable, dialogue_id, triggers VNManager | `scripts/components/npc.gd` | — |
| 3.3 | Create `npc.tscn` — sprite, collision, interaction prompt | `scenes/characters/npc.tscn` | — |
| 3.4 | Create 2 sample NPCs + dialogue files | `database/characters/elder.tres`, `database/characters/merchant.tres`, `database/dialogue/elder_intro.dialogue`, `database/dialogue/merchant_gossip.dialogue` | — |

### Dependencies

- Milestone 2 (player movement)
- VNManager (exists)

### Save Integration

- VNManager variable store already handles dialogue state
- Player position already saved (from M2)

### Sample Data

- 2 NPC character resources
- 2 dialogue files (5-10 lines each)

### Validation

- [ ] NPC appears in exploration map
- [ ] Interaction prompt appears when near NPC
- [ ] Pressing E opens VN dialogue
- [ ] Dialogue text displays correctly
- [ ] Choices work (if any)
- [ ] Closing dialogue returns to exploration
- [ ] One-time NPCs don't repeat dialogue

---

## Milestone 4: "World Flow" — Navigation Integration

**Goal**: Player can flow through VN → World Map → Region Hub → Building → Exploration with transitions.

**Why now**: World Navigation scenes already exist. Wiring them creates the full world structure.

**Complexity**: Medium

**Playable result**: Watch VN → World Map → click region → enter hub → enter building → walk → exit back

### Tasks

| # | Task | Files to Create | Files to Modify |
|---|------|----------------|-----------------|
| 4.1 | Wire VN end → SceneManager → WorldMap | — | `scripts/managers/vn/vn_manager.gd` |
| 4.2 | Wire WorldMap region selection → RegionHub | — | `scripts/world/world_map.gd` |
| 4.3 | Wire RegionHub building selection → BuildingInterior | — | `scripts/world/region_hub.gd` |
| 4.4 | Wire BuildingInterior → placeholder exploration map | — | `scripts/world/building_interior.gd` |
| 4.5 | Wire Exploration exit → RegionHub | — | `scripts/world/player_controller.gd` |
| 4.6 | Implement SceneManager pending data pattern | — | `autoload/scene_manager.gd` |
| 4.7 | Test full navigation loop | — | — |

### Dependencies

- Milestone 3 (NPCs exist to place in buildings)
- World Navigation scenes (exist)
- NavigationManager (exists)
- SceneManager (exists)

### Save Integration

Add navigation state:

```gdscript
# In SaveManager
func get_navigation_data() -> Dictionary:
    return {
        "current_region_id": navigation_manager.current_region_id,
        "current_building_id": navigation_manager.current_building_id,
        "previous_region_id": navigation_manager.previous_region_id
    }
```

### Sample Data

Already exists: 2 regions, 4 buildings, 1 shop, 2 region connections

### Validation

- [ ] VN ends → World Map appears
- [ ] Clicking a region → RegionHub loads with correct data
- [ ] Clicking a building → BuildingInterior loads
- [ ] Entering exploration map from building works
- [ ] Exiting exploration → returns to correct hub
- [ ] All transitions have fade effect
- [ ] Player state persists across transitions

---

## Milestone 5: "Fight" — Battle Foundation

**Goal**: Player encounters an enemy, enters battle, uses Attack command, wins or loses.

**Why now**: Core gameplay loop. Everything after (quests, rewards) depends on battle.

**Complexity**: High

**Playable result**: Walk → press B (test trigger) → enter battle → Attack → win/lose → return to exploration

### Tasks

| # | Task | Files to Create | Files to Modify |
|---|------|----------------|-----------------|
| 5.1 | Implement `battle_manager.gd` — state machine, AGI turn order, Attack command | `scripts/managers/battle_manager.gd` | — |
| 5.2 | Implement `battle_actor.gd` — stat access, HP/SP management | `scripts/utilities/battle_actor.gd` | — |
| 5.3 | Create `battle.tscn` — root battle scene | `scenes/battle/battle.tscn` | — |
| 5.4 | Create `battle_command_menu.tscn` — Attack button | `scenes/battle/battle_command_menu.tscn` | — |
| 5.5 | Create `battle_party_panel.tscn` — party HP bars | `scenes/battle/battle_party_panel.tscn` | — |
| 5.6 | Create `battle_enemy_panel.tscn` — enemy sprites + HP | `scenes/battle/battle_enemy_panel.tscn` | — |
| 5.7 | Create `battle_log.tscn` — action text display | `scenes/battle/battle_log.tscn` | — |
| 5.8 | Create manual encounter trigger (press B in exploration) | — | `scripts/world/player_controller.gd` |
| 5.9 | Create 2 sample enemies + 1 enemy group | `database/enemies/slime.tres`, `database/enemies/goblin.tres`, `database/enemies/group_forest.tres` | — |
| 5.10 | Create 1 sample skill (Attack) | `database/skills/attack.tres` | — |
| 5.11 | Add party state to save data | — | `autoload/save_manager.gd` |

### Dependencies

- Milestone 4 (world flow to reach battle trigger)
- Milestone 2 (exploration scene for encounter)
- EnemyResource (exists)
- SkillResource (exists)

### Save Integration

```gdscript
# In SaveManager
func get_party_data() -> Dictionary:
    return {
        "members": [
            {
                "character_id": "hero",
                "hp": 100,
                "sp": 50,
                "level": 1,
                "exp": 0
            }
        ]
    }
```

### Sample Data

- 2 enemy resources (Slime, Goblin)
- 1 enemy group resource
- 1 skill resource (Attack)

### Validation

- [ ] Pressing B in exploration starts battle
- [ ] Battle scene loads with party and enemies
- [ ] Turn order displays correctly
- [ ] Attack command deals damage
- [ ] Enemy attacks back
- [ ] Victory screen appears when all enemies defeated
- [ ] Defeat screen appears when all party down
- [ ] Returning to exploration works after battle

---

## Milestone 6: "Fight Smarter" — Full Command Set

**Goal**: Full battle commands: Skills, Items, Guard, Flee.

**Why now**: Completes battle system before rewards integration.

**Complexity**: Medium

**Playable result**: Full turn-based combat with all commands

### Tasks

| # | Task | Files to Create | Files to Modify |
|---|------|----------------|-----------------|
| 6.1 | Add Skill command (selection, SP cost, targeting, execution) | — | `scripts/managers/battle_manager.gd`, `scenes/battle/battle_command_menu.tscn` |
| 6.2 | Add Item command (selection from inventory, execution) | — | `scripts/managers/battle_manager.gd`, `scenes/battle/battle_command_menu.tscn` |
| 6.3 | Add Guard (50% damage reduction) | — | `scripts/managers/battle_manager.gd` |
| 6.4 | Add Flee (AGI-based success chance) | — | `scripts/managers/battle_manager.gd` |
| 6.5 | Expand damage calc (elemental multipliers, critical hits, status data structures) | — | `scripts/managers/battle_manager.gd` |
| 6.6 | Create 3 more skills (Heal, Fire, Guard Up) | `database/skills/heal.tres`, `database/skills/fire.tres`, `database/skills/guard_up.tres` | — |

### Dependencies

- Milestone 5 (battle foundation)

### Save Integration

None — battle state doesn't persist.

### Sample Data

- 3 skill resources (Heal, Fire, Guard Up)

### Validation

- [ ] Skill menu shows available skills
- [ ] Selecting a skill with insufficient SP shows error
- [ ] Skills deal correct damage/healing
- [ ] Item menu shows available items
- [ ] Using item in battle works
- [ ] Guard reduces incoming damage by 50%
- [ ] Flee succeeds/fails based on AGI
- [ ] All commands work in correct turn order

---

## Milestone 7: "Loot" — Inventory + Rewards

**Goal**: Battle victory grants EXP, currency, items. Player can view/use/equip items.

**Why now**: Rewards create the progression loop. Inventory makes rewards meaningful.

**Complexity**: Medium

**Playable result**: Battle victory → items in inventory → open inventory → use potion → equip sword

### Tasks

| # | Task | Files to Create | Files to Modify |
|---|------|----------------|-----------------|
| 7.1 | Implement `inventory_manager.gd` — add/remove/use/equip/currency | `scripts/managers/inventory_manager.gd` | — |
| 7.2 | Create `inventory_screen.tscn` — item grid, category tabs, detail panel | `scenes/ui/inventory_screen.tscn` | — |
| 7.3 | Create `item_slot.tscn` — icon, quantity, rarity border | `scenes/ui/item_slot.tscn` | — |
| 7.4 | Wire victory rewards (EXP → level, currency → wallet, items → inventory) | — | `scripts/managers/battle_manager.gd` |
| 7.5 | Wire item usage (inventory screen + battle item command) | — | `scripts/managers/inventory_manager.gd`, `scripts/managers/battle_manager.gd` |
| 7.6 | Create 5 sample items | `database/items/potion.tres`, `database/items/hi_potion.tres`, `database/items/antidote.tres`, `database/items/iron_sword.tres`, `database/items/leather_armor.tres` | — |
| 7.7 | Add inventory data to SaveManager | — | `autoload/save_manager.gd` |

### Dependencies

- Milestone 6 (full battle for reward testing)
- ItemResource (exists)

### Save Integration

```gdscript
# In SaveManager
func get_inventory_data() -> Dictionary:
    return {
        "items": [
            {"item_id": "potion", "quantity": 3},
            {"item_id": "iron_sword", "quantity": 1}
        ],
        "equipment": {
            "hero": {
                "weapon": "iron_sword",
                "body": "leather_armor"
            }
        },
        "currency": 500
    }
```

### Sample Data

- 5 item resources (Potion, Hi-Potion, Antidote, Iron Sword, Leather Armor)

### Validation

- [ ] Battle victory grants EXP, currency, items
- [ ] EXP accumulates and levels up character
- [ ] Currency displays correctly
- [ ] Inventory screen opens with correct items
- [ ] Category tabs filter items correctly
- [ ] Item detail panel shows name, description, stats
- [ ] Using a consumable removes it from inventory
- [ ] Equipping weapon changes stats
- [ ] Unequipping works
- [ ] Inventory persists after save/load

---

## Milestone 8: "Goal" — Quest System

**Goal**: Player accepts a quest, completes objectives (talk, defeat, collect, reach), claims rewards.

**Why now**: Quests give purpose to everything built. Depends on all prior systems.

**Complexity**: High

**Playable result**: Accept quest → defeat enemies → collect items → talk to NPC → complete → claim rewards

### Tasks

| # | Task | Files to Create | Files to Modify |
|---|------|----------------|-----------------|
| 8.1 | Implement `quest_manager.gd` — lifecycle, stage advancement, objective tracking | `scripts/managers/quest_manager.gd` | — |
| 8.2 | Create `quest_log.tscn` — quest list, detail, objectives, rewards | `scenes/ui/quest_log.tscn` | — |
| 8.3 | Wire VN dialogue → quest accept/complete | — | `scripts/managers/vn/vn_command_executor.gd` |
| 8.4 | Wire battle defeat → quest objective update | — | `scripts/managers/battle_manager.gd` |
| 8.5 | Wire item collect → quest objective update | — | `scripts/managers/inventory_manager.gd` |
| 8.6 | Wire NPC talk → quest objective update | — | `scripts/components/npc.gd` |
| 8.7 | Create 2 sample quests | `database/quests/prologue_main.tres`, `database/quests/herb_gathering.tres` | — |
| 8.8 | Add quest states to SaveManager | — | `autoload/save_manager.gd` |

### Dependencies

- Milestone 7 (quest rewards → inventory)
- Milestone 5 (defeat objectives)
- Milestone 3 (talk objectives)
- Milestone 4 (reach objectives)
- QuestResource (exists)

### Save Integration

```gdscript
# In SaveManager
func get_quest_data() -> Dictionary:
    return {
        "quests": {
            "prologue_main": {
                "state": "ACTIVE",
                "current_stage": "stage_1",
                "objectives": {
                    "talk_to_elder": {"current_count": 1, "required_count": 1},
                    "defeat_slimes": {"current_count": 2, "required_count": 3}
                }
            }
        }
    }
```

### Sample Data

- 2 quest resources (main story quest, side quest)

### Validation

- [ ] NPC dialogue offers quest accept
- [ ] Accepting quest adds it to quest log
- [ ] Quest log shows active quests with objectives
- [ ] Defeating enemies updates defeat objective counter
- [ ] Collecting items updates collect objective counter
- [ ] Talking to NPC updates talk objective counter
- [ ] All objectives complete → quest ready to turn in
- [ ] Turning in quest grants rewards
- [ ] Completed quest moves to completed list
- [ ] Quest state persists after save/load

---

## Milestone 9: "Remember" — Save/Load

**Goal**: Player saves the game, quits, loads, and continues exactly where they left off.

**Why now**: Save serialization code exists per system. This milestone wires the UI.

**Complexity**: Medium

**Playable result**: Play → save → quit → main menu → load → continue from exact state

### Tasks

| # | Task | Files to Create | Files to Modify |
|---|------|----------------|-----------------|
| 9.1 | Create `save_screen.tscn` — save slots, load buttons, confirm dialog, timestamps | `scenes/ui/save_screen.tscn` | — |
| 9.2 | Wire SaveManager to save screen | — | `autoload/save_manager.gd` |
| 9.3 | Verify every system's to_dict/from_dict | — | `autoload/save_manager.gd` |
| 9.4 | Test full save → load cycle | — | — |

### Dependencies

- All previous milestones (all systems must be serializable)

### Save Integration

This milestone wires the UI. The serialization code already exists from previous milestones.

### Validation

- [ ] Save screen shows available slots
- [ ] Saving to a slot shows timestamp and scene name
- [ ] Loading from main menu restores exact state
- [ ] Player position is correct after load
- [ ] Inventory is correct after load
- [ ] Quest states are correct after load
- [ ] VN variables are correct after load
- [ ] Party stats are correct after load
- [ ] Global flags are correct after load
- [ ] Loading during gameplay works (not just from menu)
- [ ] Save file handles missing data gracefully

---

## Milestone 10: "Content" — Fill the Region

**Goal**: One fully playable region with 15-30 minutes of content.

**Why now**: All systems exist. Fill them with real content.

**Complexity**: Medium

**Playable result**: Full prototype region playthrough

### Tasks

| # | Task | Files to Create | Files to Modify |
|---|------|----------------|-----------------|
| 10.1 | Create full exploration map `verdant_forest.tscn` | `scenes/exploration/verdant_forest.tscn` | — |
| 10.2 | Expand prologue dialogue to 50+ lines | — | `database/dialogue/sample_prologue.dialogue` |
| 10.3 | Create town NPC dialogue | `database/dialogue/elder_intro.dialogue`, `database/dialogue/merchant_gossip.dialogue`, `database/dialogue/innkeeper.dialogue` | — |
| 10.4 | Create 3 more enemies | `database/enemies/wolf.tres`, `database/enemies/bat.tres`, `database/enemies/mushroom.tres` | — |
| 10.5 | Create 5 more items | `database/items/wooden_stick.tres`, `database/items/cloth_robe.tres`, `database/items/herb.tres`, `database/items/slime_jelly.tres`, `database/items/goblin_coin.tres` | — |
| 10.6 | Create 1 more side quest | `database/quests/inn_delivery.tres` | — |
| 10.7 | Add random encounters to exploration map | — | `scripts/world/player_controller.gd` |
| 10.8 | Full playthrough test: Boot to Save | — | — |

### Dependencies

- Milestone 9 (all systems exist)

### Validation

- [ ] Full playthrough from boot to save without errors
- [ ] Exploration map has varied terrain
- [ ] Random encounters trigger at appropriate rate
- [ ] All NPCs have dialogue
- [ ] All quests are completable
- [ ] All items are obtainable
- [ ] All enemies are fightable
- [ ] Playthrough takes 15-30 minutes

---

## Milestone 11: "Polish" — Edge Cases + Cleanup

**Goal**: No game-breaking bugs in the main loop.

**Why now**: All content exists. Now harden it.

**Complexity**: Low

**Playable result**: Polished prototype with no obvious bugs

### Tasks

| # | Task | Files to Create | Files to Modify |
|---|------|----------------|-----------------|
| 11.1 | Add settings screen (audio volume only) | `scenes/ui/settings_screen.tscn` | — |
| 11.2 | Add VN history panel + quick menu (if deferred from M1) | `scenes/ui/vn/vn_history_panel.tscn`, `scenes/ui/vn/vn_quick_menu.tscn` | — |
| 11.3 | Fix edge cases: empty inventory, no quests, pre-state save, 1-enemy battle, game over | — | Various |
| 11.4 | Verify all scene transitions with save data | — | — |
| 11.5 | Update documentation | — | `docs/current_tasks.md`, `docs/roadmap.md` |

### Dependencies

- Milestone 10 (content exists to test against)

### Validation

- [ ] Settings screen adjusts BGM/SFX volume
- [ ] Empty inventory shows "no items" message
- [ ] No active quests shows "no quests" message
- [ ] Saving before any game state works
- [ ] Battle with 1 enemy works
- [ ] All party defeated shows game over screen
- [ ] Game over → retry or main menu works
- [ ] All scene transitions work with save data
- [ ] No crashes in full playthrough

---

## Parallel Work

| Work | Parallel With | Why |
|------|---------------|-----|
| Sample character data creation | M1 or M2 | Just .tres files, no code |
| Sample enemy data creation | M5 or M6 | Just .tres files, no code |
| Sample item data creation | M7 | Just .tres files, no code |
| Sample quest data creation | M8 | Just .tres files, no code |
| Settings screen | M10 or M11 | Depends only on existing AudioManager |
| VN History + Quick Menu scenes | M10 or M11 | Scenes without new scripts |
| Exploration map visual design | M4 or higher | No code dependency |

---

## Suggested Git Commit Boundaries

| Commit | Message | Scope |
|--------|---------|-------|
| 1 | `feat: create 4 essential VN editor scenes` | 4 .tscn files |
| 2 | `feat: implement player controller and placeholder map` | player_controller.gd, player.tscn, placeholder_map.tscn |
| 3 | `feat: implement interactable base and NPC interaction` | interactable.gd, npc.gd, npc.tscn, 2 dialogue files |
| 4 | `feat: wire world navigation flow` | SceneManager wires only |
| 5 | `feat: implement battle foundation with Attack command` | battle_manager.gd, battle_actor.gd, 4 battle scenes |
| 6 | `feat: add Skills, Items, Guard, Flee to battle` | Extends battle manager + scene |
| 7 | `feat: create sample enemies and enemy groups` | 2 .tres enemies + 1 group |
| 8 | `feat: implement inventory manager and rewards wiring` | inventory_manager.gd, 2 inventory scenes |
| 9 | `feat: create sample items` | 5 .tres items |
| 10 | `feat: implement quest manager with objective tracking` | quest_manager.gd, quest_log.tscn |
| 11 | `feat: create sample quests with event wiring` | 2 .tres quests, dialogue event tests |
| 12 | `feat: implement save/load screen and end-to-end persistence` | save_screen.tscn, serialization validation |
| 13 | `feat: create full verdant forest exploration map` | verdant_forest.tscn + expanded NPC/content |
| 14 | `feat: add settings screen (audio)` | settings_screen.tscn |
| 15 | `feat: add VN history panel and quick menu scenes` | 2 .tscn files |
| 16 | `fix: edge case handling and bug fixes` | Various |
| 17 | `chore: update documentation for Phase 2` | Docs |

---

## AI Agent Execution Order

If distributing across multiple AI agents:

| Agent | Milestone | New Scripts | New Scenes | New Data Files |
|-------|-----------|-------------|------------|----------------|
| Agent 1 | M1 | 0 | 4 | 0 |
| Agent 2 | M2 | 1 | 2 | 1 |
| Agent 3 | M3 | 2 | 1 | 4 |
| Agent 4 | M4 | 0 | 0 | 0 (wiring only) |
| Agent 5 | M5 | 2 | 5 | 4 |
| Agent 6 | M6 | 0 | 0 | 3 |
| Agent 7 | M7 | 1 | 2 | 5 |
| Agent 8 | M8 | 1 | 1 | 2 |
| Agent 9 | M9 | 0 | 1 | 0 |
| Agent 10 | M10 | 0 | 1 | 10+ |
| Agent 11 | M11 | 0 | 3 | 0 |

---

## Related

- [roadmap.md](roadmap.md) — High-level roadmap
- [current_tasks.md](current_tasks.md) — Active tasks
- [architecture.md](architecture.md) — System architecture
- [game_design.md](game_design.md) — Game design