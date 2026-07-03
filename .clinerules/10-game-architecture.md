---

description: Game architecture and gameplay systems
alwaysApply: true
-----------------

# Game Architecture

The game consists of independent gameplay modules.

Core systems:

* Visual Novel
* World Navigation
* Exploration
* Turn-Based Battle
* RPG Systems
* Save System

These modules should communicate through managers, signals, or shared data.

---

# Gameplay Flow

Main Menu

↓

Visual Novel

↓

World Map

↓

Town

↓

Building

↓

Exploration

↓

Battle

↓

Reward

↓

Story Progress

Never mix gameplay responsibilities between modules.

---

# Managers

Only create managers for global systems.

Examples:

DialogueManager

QuestManager

BattleManager

SceneManager

SaveManager

AudioManager

Do not create managers for one-time features.

---

# Data Ownership

Dialogue owns dialogue.

Battle owns battle.

Inventory owns inventory.

Avoid multiple systems modifying the same data directly.

---

# Expansion

Assume new regions,

new quests,

new NPCs,

new battle mechanics

will be added later without rewriting existing systems.
