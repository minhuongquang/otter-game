class_name VNStateMachine
extends Node

## State machine for Visual Novel execution flow.
## Manages the sequence of states: IDLE → TYPING → WAITING → CHOICE → COMMAND → ...
##
## States:
##   IDLE     - Not running any dialogue
##   TYPING   - Typewriter effect is playing for a dialogue line
##   WAITING  - Waiting for player input (advance click or auto-timer)
##   CHOICE   - Waiting for player to select a choice
##   COMMAND  - Executing a blocking command (fade, wait, shake, etc.)
##   SKIPPING - Skip mode active, rapidly iterating through commands
##   PAUSED   - Game paused (VN is suspended)
##   ENDED    - Dialogue sequence complete

enum VNState {
	IDLE,
	TYPING,
	WAITING,
	CHOICE,
	COMMAND,
	SKIPPING,
	PAUSED,
	ENDED
}

signal state_changed(old_state: VNState, new_state: VNState)
signal command_index_changed(index: int)
signal choice_encountered(choices: Array[VNChoiceData])
signal dialogue_ended()

var current_state: VNState = VNState.IDLE
var command_index: int = 0
var commands: Array[VNCommand] = []

# Label resolution: label_name -> command_index
var _label_map: Dictionary = {}

## Start executing a command array from index 0.
func run(command_array: Array[VNCommand]) -> void:
	commands = command_array
	command_index = 0
	_label_map.clear()
	
	# Build label map
	for i in range(commands.size()):
		var cmd: VNCommand = commands[i]
		if cmd is VNCmdLabel:
			_label_map[cmd.label_name] = i
	
	_change_state(VNState.COMMAND)
	_advance_to_next()

## Advance to the next command in the sequence.
func advance() -> void:
	if current_state == VNState.WAITING:
		_change_state(VNState.COMMAND)
		command_index += 1
		_advance_to_next()
	elif current_state == VNState.TYPING:
		# Signal to skip the typewriter
		_change_state(VNState.WAITING)
		emit_signal("command_index_changed", command_index)
	elif current_state == VNState.COMMAND:
		# Advance through non-blocking command
		command_index += 1
		_advance_to_next()

## Jump to a label by name. Used by branches and choice targets.
func jump_to_label(label_name: String) -> bool:
	if _label_map.has(label_name):
		command_index = _label_map[label_name]
		_change_state(VNState.COMMAND)
		_advance_to_next()
		return true
	
	push_error("VNStateMachine: Label not found: %s" % label_name)
	return false

## Handle a player choice selection.
func make_choice(choice_index: int, choices: Array[VNChoiceData]) -> bool:
	if current_state != VNState.CHOICE:
		return false
	
	if choice_index < 0 or choice_index >= choices.size():
		return false
	
	var chosen: VNChoiceData = choices[choice_index]
	
	# Execute choice effects
	for effect in chosen.effects:
		# Effects are applied by the executor
		pass
	
	# Jump to target label
	if not chosen.target_label.is_empty():
		return jump_to_label(chosen.target_label)
	
	# If no target, advance to next command
	_change_state(VNState.COMMAND)
	command_index += 1
	_advance_to_next()
	return true

## Skip to the end of the dialogue sequence.
func skip_to_end() -> void:
	command_index = commands.size()
	_change_state(VNState.ENDED)
	emit_signal("dialogue_ended")

## Check if dialogue is still active.
func is_active() -> bool:
	return current_state != VNState.IDLE and current_state != VNState.ENDED

## Pause the dialogue (e.g., game paused).
func pause() -> void:
	if current_state not in [VNState.IDLE, VNState.ENDED, VNState.PAUSED]:
		_change_state(VNState.PAUSED)

## Resume the dialogue.
func resume() -> void:
	if current_state == VNState.PAUSED:
		_change_state(VNState.COMMAND)
		_advance_to_next()

## Get the current command (if any).
func get_current_command() -> VNCommand:
	if command_index >= 0 and command_index < commands.size():
		return commands[command_index]
	return null

# === Internal ===

func _change_state(new_state: VNState) -> void:
	var old_state: VNState = current_state
	current_state = new_state
	emit_signal("state_changed", old_state, new_state)

func _advance_to_next() -> void:
	if command_index >= commands.size():
		_change_state(VNState.ENDED)
		emit_signal("dialogue_ended")
		return
	
	var cmd: VNCommand = commands[command_index]
	emit_signal("command_index_changed", command_index)
	
	# Skip label commands silently
	if cmd is VNCmdLabel:
		command_index += 1
		_advance_to_next()
		return
	
	# Handle dialogue lines: transition to TYPING
	if cmd is VNCmdDialogueLine:
		_change_state(VNState.TYPING)
		return
	
	# Handle choices: transition to CHOICE
	if cmd is VNCmdChoice:
		_change_state(VNState.CHOICE)
		emit_signal("choice_encountered", cmd.choices)
		return
	
	# Handle branches: evaluate and jump
	if cmd is VNCmdBranch:
		# Branch evaluation is handled by the executor
		_change_state(VNState.COMMAND)
		return
	
	# For blocking commands
	if cmd.blocking:
		_change_state(VNState.COMMAND)
		return
	
	# For non-blocking commands, execute and continue
	_change_state(VNState.COMMAND)
	# The executor will call back to advance