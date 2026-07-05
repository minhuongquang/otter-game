## BattleEnums — shared enum definitions for the battle system.
class_name BattleEnums
extends RefCounted

# ─── Command Type ─────────────────────────────────────────────────────────────
## Type of action a BattleCommand represents.
enum CommandType { ATTACK, SKILL, GUARD, ITEM, FLEE }

# ─── Team ─────────────────────────────────────────────────────────────────────
## Which side of the battle an actor belongs to.
enum Team { PLAYER, ENEMY }

# ─── Element ──────────────────────────────────────────────────────────────────
## Elemental affinity used for damage matchup calculations.
enum Element { NEUTRAL, FIRE, WATER, WIND, EARTH, LIGHTNING, ICE, LIGHT, DARK }

# ─── Battle Outcome ───────────────────────────────────────────────────────────
## Result of a battle. Emitted by BattleStateMachine when outcome is known.
enum BattleOutcome { VICTORY, DEFEAT, FLEE, ABORTED }
