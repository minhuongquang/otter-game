---

description: Software architecture principles
alwaysApply: true
-----------------

# Architecture Principles

Always follow:

* SOLID
* DRY
* KISS
* YAGNI
* Separation of Concerns
* Composition over Inheritance

---

# Single Responsibility

Each class should have one responsibility.

Examples:

DialogueManager

QuestManager

InventoryManager

BattleManager

AudioManager

Avoid "manager" classes that control unrelated systems.

---

# Loose Coupling

Prefer:

* Signals
* Events
* Interfaces
* Dependency Injection when appropriate

Avoid direct references between unrelated systems.

---

# Modular Design

Create reusable systems.

Do not create one-off implementations.

Every system should be usable by future game content.

---

# Scene Architecture

Prefer:

Small reusable scenes.

Avoid giant scene trees.

Reusable objects should be independent scenes whenever practical.

---

# Data Ownership

Every system should own its own data.

Avoid shared mutable state.

Autoloads should only exist for global systems.

---

# Extensibility

Assume future expansion.

When designing a feature, ask:

Can this support twice as many maps?

Can this support hundreds of NPCs?

Can this support DLC?

Prefer solutions that scale naturally.
