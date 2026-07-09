## TurnManager — owns turn order and advances turns.
## Round-robin only for M5. AGI sorting deferred to M6.
class_name TurnManager
extends RefCounted

# ─── State ────────────────────────────────────────────────────────────────────
var _actors: Array[BattleActor] = []
var _current_index: int = -1

# ─── Public API ───────────────────────────────────────────────────────────────
## Initialize turn order from an array of actors. Order is caller-defined.
func initialize(actors: Array[BattleActor]) -> void:
	_actors = actors.duplicate()
	_current_index = -1
	strip_defeated()

## Current actor without side effects. Returns null when order is empty.
func current_actor() -> BattleActor:
	if _actors.is_empty():
		return null
	if _current_index < 0 or _current_index >= _actors.size():
		return null
	return _actors[_current_index]

## Advance to next living actor and return it. Strips defeated actors internally.
## Returns null if no living actors remain.
func next_turn() -> BattleActor:
	if _actors.is_empty():
		return null
	_current_index = (_current_index + 1) % _actors.size()
	# skip dead actors, but guard against infinite loops
	var checked := 0
	while _actors[_current_index].is_defeated() and checked < _actors.size():
		_current_index = (_current_index + 1) % _actors.size()
		checked += 1
	if _actors[_current_index].is_defeated():
		return null
	return _actors[_current_index]

## Preview next actor without advancing the turn. Returns null if none.
func peek_next_actor() -> BattleActor:
	if _actors.is_empty() or _current_index < 0:
		return null
	var peek_index := (_current_index + 1) % _actors.size()
	var checked := 0
	while _actors[peek_index].is_defeated() and checked < _actors.size():
		peek_index = (peek_index + 1) % _actors.size()
		checked += 1
	if _actors[peek_index].is_defeated():
		return null
	return _actors[peek_index]

## Remove defeated actors from the turn order. Called after damage resolution.
func strip_defeated() -> void:
	_actors = _actors.filter(func(a: BattleActor) -> bool: return a.is_alive())
	# clamp index after removal
	if _actors.is_empty():
		_current_index = -1
	elif _current_index >= _actors.size():
		_current_index = _actors.size() - 1

## All living actors in turn order.
func living_actors() -> Array[BattleActor]:
	var result: Array[BattleActor] = []
	for a in _actors:
		if a.is_alive():
			result.append(a)
	return result

## Whether the turn order still contains at least one living actor.
func has_living() -> bool:
	for a in _actors:
		if a.is_alive():
			return true
	return false