## BattleStateMachine — tracks battle state and validates transitions.
## Pure state machine. No gameplay logic, no scene access, no node inheritance.
class_name BattleStateMachine
extends RefCounted

# ─── States ───────────────────────────────────────────────────────────────────
enum State {
	IDLE,
	INITIALIZING,
	PLAYER_TURN,
	ENEMY_TURN,
	EXECUTING_ACTION,
	CHECK_RESULT,
	VICTORY,
	DEFEAT,
	CLEANUP,
	FINISHED,
}

# ─── Signals ──────────────────────────────────────────────────────────────────
signal state_changed(old_state: State, new_state: State)

## Emitted exactly once when outcome becomes known (VICTORY, DEFEAT, FLEE, ABORTED).
signal battle_finished(outcome: BattleEnums.BattleOutcome)

# ─── State ────────────────────────────────────────────────────────────────────
var current_state: State = State.IDLE

# ─── Transition Map ───────────────────────────────────────────────────────────
var _valid_transitions: Dictionary = {}

# ─── Lifecycle ────────────────────────────────────────────────────────────────
func _init() -> void:
	_build_transition_map()

# ─── Public API ───────────────────────────────────────────────────────────────
## Attempt to transition to new_state. Returns true on success.
## Emits state_changed and (when applicable) battle_finished.
func transition_to(new_state: State) -> bool:
	if not can_transition_to(new_state):
		push_error("BattleStateMachine: invalid transition %s -> %s." % [State.keys()[current_state], State.keys()[new_state]])
		return false

	var old_state := current_state
	current_state = new_state
	state_changed.emit(old_state, new_state)

	if new_state in [State.VICTORY, State.DEFEAT]:
		var outcome: BattleEnums.BattleOutcome
		match new_state:
			State.VICTORY:
				outcome = BattleEnums.BattleOutcome.VICTORY
			State.DEFEAT:
				outcome = BattleEnums.BattleOutcome.DEFEAT
		battle_finished.emit(outcome)
	elif new_state == State.FINISHED and old_state == State.CLEANUP:
		# Outcome already emitted during VICTORY/DEFEAT.
		# FLEE/ABORTED handled by caller emitting directly before CLEANUP (future).
		pass

	return true

## Check whether a transition to new_state is legal from the current state.
func can_transition_to(new_state: State) -> bool:
	var allowed: Array = _valid_transitions.get(current_state, [])
	return allowed.has(new_state)

## Return all valid target states from the current state. Useful for debugging/tooling.
func get_valid_transitions() -> Array[State]:
	return _valid_transitions.get(current_state, [])

## Convenience: check whether the machine is in a given state.
func is_in(state: State) -> bool:
	return current_state == state

## Whether battle is active (not IDLE and not FINISHED).
func is_active() -> bool:
	return current_state != State.IDLE and current_state != State.FINISHED

## Whether the machine is in a terminal state.
func is_terminal() -> bool:
	return current_state in [State.VICTORY, State.DEFEAT, State.FINISHED]

## Reset to IDLE without emitting signals. For reusing the instance.
func reset() -> void:
	current_state = State.IDLE

# ─── Private ──────────────────────────────────────────────────────────────────
func _build_transition_map() -> void:
	_valid_transitions = {
		State.IDLE:              [State.INITIALIZING],
		State.INITIALIZING:     [State.PLAYER_TURN, State.ENEMY_TURN],
		State.PLAYER_TURN:      [State.EXECUTING_ACTION, State.CHECK_RESULT],
		State.ENEMY_TURN:       [State.EXECUTING_ACTION],
		State.EXECUTING_ACTION: [State.CHECK_RESULT],
		State.CHECK_RESULT:     [State.PLAYER_TURN, State.ENEMY_TURN, State.VICTORY, State.DEFEAT],
		State.VICTORY:          [State.CLEANUP],
		State.DEFEAT:           [State.CLEANUP],
		State.CLEANUP:          [State.FINISHED],
		State.FINISHED:         [],
	}