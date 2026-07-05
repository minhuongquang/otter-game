extends Node

## Main manager for the Visual Novel dialogue system.
## Owns and coordinates: StateMachine, CommandExecutor, VariableStore,
## Typewriter, AutoSkip, and History.
##
## Usage:
##   VNManager.start_dialogue("prologue_001")
##
## All systems communicate through EventBus for loose coupling.

signal vn_started(dialogue_id: String)
signal vn_ended(dialogue_id: String)
signal vn_line_displayed(speaker: String, text: String, emotion: String)
signal vn_choice_made(choice_index: int, choice_text: String)
signal vn_auto_mode_changed(enabled: bool)
signal vn_skip_mode_changed(enabled: bool)

# === Sub-systems ===
var state_machine: VNStateMachine
var executor: VNCommandExecutor
var variable_store: VNVariableStore
var typewriter: VNTypewriter
var auto_skip: VNAutoSkip
var history: VNHistory

# === State ===
var current_dialogue_id: String = ""
var _current_resource: VNDialogueResource = null
var is_active: bool = false

# === UI References (set by VN scene) ===
var vn_panel: Node = null  # Reference to the VN UI panel

func _init() -> void:
	# Create sub-systems
	state_machine = VNStateMachine.new()
	add_child(state_machine)
	
	executor = VNCommandExecutor.new()
	add_child(executor)
	
	variable_store = VNVariableStore.new()
	
	typewriter = VNTypewriter.new()
	add_child(typewriter)
	
	auto_skip = VNAutoSkip.new()
	add_child(auto_skip)
	
	history = VNHistory.new()

func _ready() -> void:
	# Connect signals
	state_machine.state_changed.connect(_on_state_changed)
	state_machine.command_index_changed.connect(_on_command_index_changed)
	state_machine.choice_encountered.connect(_on_choice_encountered)
	state_machine.dialogue_ended.connect(_on_dialogue_ended)
	
	typewriter.finished.connect(_on_typewriter_finished)
	
	executor.blocking_command_finished.connect(_on_blocking_command_finished)
	
	auto_skip.auto_mode_changed.connect(func(e): emit_signal("vn_auto_mode_changed", e))
	auto_skip.skip_mode_changed.connect(func(e): emit_signal("vn_skip_mode_changed", e))
	
	# Initialize executor with our sub-systems
	executor.initialize(state_machine, variable_store)
	
	# Listen to EventBus events
	EventBus.listen("vn_advance", _on_advance_event)
	EventBus.listen("vn_make_choice", _on_make_choice_event)
	EventBus.listen("vn_toggle_auto", _on_toggle_auto_event)
	EventBus.listen("vn_toggle_skip", _on_toggle_skip_event)
	EventBus.listen("vn_open_history", _on_open_history_event)
	EventBus.listen("game_paused", _on_game_paused)
	EventBus.listen("game_resumed", _on_game_resumed)

func _exit_tree() -> void:
	EventBus.unlisten("vn_advance", _on_advance_event)
	EventBus.unlisten("vn_make_choice", _on_make_choice_event)
	EventBus.unlisten("vn_toggle_auto", _on_toggle_auto_event)
	EventBus.unlisten("vn_toggle_skip", _on_toggle_skip_event)
	EventBus.unlisten("vn_open_history", _on_open_history_event)
	EventBus.unlisten("game_paused", _on_game_paused)
	EventBus.unlisten("game_resumed", _on_game_resumed)

# === Public API ===

## Start a dialogue sequence by ID.
func start_dialogue(dialogue_id: String) -> void:
	if is_active:
		push_warning("VNManager: Dialogue already active, ending current one.")
		end_dialogue()
	
	# Load the dialogue resource from Database
	var resource: VNDialogueResource = Database.get_dialogue(dialogue_id)
	if resource == null:
		push_error("VNManager: Dialogue not found: %s" % dialogue_id)
		return
	
	_current_resource = resource
	current_dialogue_id = dialogue_id
	is_active = true
	
	# Reset variable store
	variable_store.reset()
	
	# Initialize variables from resource if available
	# (Variables are stored within the resource metadata)
	
	# Execute on_start events
	for event in resource.on_start_events:
		_execute_event(event)
	
	# Set background if specified
	if resource.background != null:
		EventBus.emit_event("vn_change_background", {
			"texture_path": resource.background.resource_path if resource.background.resource_path else "",
			"transition": "fade",
			"duration": 0.5
		})
	
	# Set BGM if specified
	if resource.bgm != null:
		EventBus.emit_event("vn_play_bgm", {
			"audio_path": resource.bgm.resource_path if resource.bgm.resource_path else "",
			"fade_in": 0.5
		})
	
	# Emit start event
	EventBus.emit_event("vn_started", {"dialogue_id": dialogue_id})
	emit_signal("vn_started", dialogue_id)
	
	# Run the state machine
	state_machine.run(resource.commands)

## Advance to the next dialogue line.
func advance() -> void:
	if not is_active:
		return
	
	# If typewriter is still typing, skip to end
	if typewriter.is_typing:
		typewriter.skip_to_end()
		return
	
	# If in auto mode, reset the auto timer
	auto_skip.reset_auto_timer()
	
	# Tell state machine to advance
	state_machine.advance()

## Make a choice selection.
func make_choice(index: int) -> void:
	if not is_active or state_machine.current_state != VNStateMachine.VNState.CHOICE:
		return
	
	# Get current command to access choices
	var current_cmd: VNCommand = state_machine.get_current_command()
	if current_cmd is VNCmdChoice:
		var choice_cmd: VNCmdChoice = current_cmd as VNCmdChoice
		if index >= 0 and index < choice_cmd.choices.size():
			var chosen: VNChoiceData = choice_cmd.choices[index]
			
			# Block choice buttons that have a condition that isn't met
			if not chosen.condition_expression.is_empty():
				if not variable_store.evaluate_condition(chosen.condition_expression):
					# Condition not met for this choice, ignore
					return
			
			# Apply choice effects
			for effect in chosen.effects:
				variable_store.apply_effect(effect)
			
			# Emit events
			EventBus.emit_event("vn_choice_made", {
				"choice_index": index,
				"choice_text": chosen.choice_text,
				"dialogue_id": current_dialogue_id
			})
			emit_signal("vn_choice_made", index, chosen.choice_text)
			
			# Tell state machine to jump to the target
			state_machine.make_choice(index, choice_cmd.choices)

## Toggle auto mode.
func toggle_auto() -> void:
	auto_skip.toggle_auto()

## Toggle skip mode.
func toggle_skip() -> void:
	auto_skip.toggle_skip()

## Open the dialogue history log.
func open_history() -> void:
	EventBus.emit_event("vn_show_history", {
		"entries": history.get_entries()
	})

## Check if dialogue is currently active.
func is_dialogue_active() -> bool:
	return is_active

## Get the current state.
func get_state() -> int:
	return state_machine.current_state

## Get the current command data as a dictionary (for UI).
func get_current_line_data() -> Dictionary:
	var cmd: VNCommand = state_machine.get_current_command()
	if cmd is VNCmdDialogueLine:
		var line_cmd: VNCmdDialogueLine = cmd as VNCmdDialogueLine
		return {
			"speaker_id": line_cmd.speaker_id,
			"display_name": line_cmd.display_name,
			"emotion": line_cmd.emotion,
			"text": line_cmd.dialogue_text,
			"voice_line": line_cmd.voice_line
		}
	return {}

## Get available choices for the current choice point.
func get_available_choices() -> Array[VNChoiceData]:
	var cmd: VNCommand = state_machine.get_current_command()
	if cmd is VNCmdChoice:
		var choice_cmd: VNCmdChoice = cmd as VNCmdChoice
		var available: Array[VNChoiceData] = []
		for choice in choice_cmd.choices:
			# Check if this choice has a condition
			if choice.condition_expression.is_empty() or variable_store.evaluate_condition(choice.condition_expression):
				available.append(choice)
		return available
	return []

## Get dialogue history entries.
func get_history() -> Array:
	return history.get_entries()

## End the current dialogue.
func end_dialogue() -> void:
	if not is_active:
		return
	
	is_active = false
	
	# Execute on_end events
	if _current_resource != null:
		for event in _current_resource.on_end_events:
			_execute_event(event)
	
	# Emit end events
	EventBus.emit_event("vn_ended", {"dialogue_id": current_dialogue_id})
	emit_signal("vn_ended", current_dialogue_id)
	
	_current_resource = null
	current_dialogue_id = ""

## Serialize VN state for save system.
func serialize() -> Dictionary:
	return {
		"dialogue_id": current_dialogue_id,
		"command_index": state_machine.command_index,
		"variables": variable_store.serialize(),
		"auto_skip": auto_skip.serialize()
	}

## Deserialize VN state from save system.
func deserialize(data: Dictionary) -> void:
	if data.has("dialogue_id") and not data["dialogue_id"].is_empty():
		var saved_id: String = data["dialogue_id"]
		var saved_index: int = data.get("command_index", 0)
		
		start_dialogue(saved_id)
		
		# Fast-forward to the saved command index
		# Note: This is a simplified approach. Full save/load
		# requires restoring exact frame state.
		state_machine.command_index = saved_index
		
		if data.has("variables"):
			variable_store.deserialize(data["variables"])
		if data.has("auto_skip"):
			auto_skip.deserialize(data["auto_skip"])

# === Internal Handlers ===

func _on_state_changed(old_state: int, new_state: int) -> void:
	pass

func _on_command_index_changed(index: int) -> void:
	var cmd: VNCommand = state_machine.get_current_command()
	if cmd == null:
		return
	
	# Dialogue lines are displayed via the UI panel (typewriter)
	if cmd.command_type == "dialogue_line":
		if vn_panel != null and vn_panel.has_method("update_dialogue"):
			var line_data := get_current_line_data()
			vn_panel.update_dialogue(line_data)
		return
	
	# Execute non-blocking commands immediately
	if not cmd.blocking:
		executor.execute(cmd)
		# For non-blocking commands, advance state machine
		if not executor.has_active_blocking():
			state_machine.advance()
	elif cmd.blocking:
		# Execute blocking commands and wait for completion
		executor.execute(cmd)

func _on_choice_encountered(choices: Array[VNChoiceData]) -> void:
	# Filter choices by conditions
	var available: Array[VNChoiceData] = []
	for choice in choices:
		if choice.condition_expression.is_empty() or variable_store.evaluate_condition(choice.condition_expression):
			available.append(choice)
	
	# Tell UI to display choices
	EventBus.emit_event("vn_show_choices", {
		"choices": available
	})

func _on_typewriter_finished() -> void:
	# Typewriter finished revealing text
	# Auto-mark the line as read
	auto_skip.mark_line_read(current_dialogue_id, state_machine.command_index)
	
	# Add to history
	var line_data := get_current_line_data()
	if not line_data.is_empty():
		history.add_entry(
			line_data.get("display_name", ""),
			line_data.get("text", ""),
			"",  # portrait_path (resolved from character_id)
			current_dialogue_id,
			state_machine.command_index
		)
	
	# Emit line displayed signal
	emit_signal("vn_line_displayed",
		line_data.get("display_name", ""),
		line_data.get("text", ""),
		line_data.get("emotion", "")
	)
	
	# If not auto/skip mode, wait for player input
	if not auto_skip.auto_mode and not auto_skip.skip_mode:
		state_machine.current_state = VNStateMachine.VNState.WAITING

func _on_blocking_command_finished() -> void:
	# Blocking command is done, advance to next
	state_machine.advance()

func _on_dialogue_ended() -> void:
	end_dialogue()

func _on_advance_event(data: Dictionary) -> void:
	advance()

func _on_make_choice_event(data: Dictionary) -> void:
	var index: int = data.get("index", -1)
	make_choice(index)

func _on_toggle_auto_event(data: Dictionary) -> void:
	toggle_auto()

func _on_toggle_skip_event(data: Dictionary) -> void:
	toggle_skip()

func _on_open_history_event(data: Dictionary) -> void:
	open_history()

func _on_game_paused(data: Dictionary) -> void:
	state_machine.pause()

func _on_game_resumed(data: Dictionary) -> void:
	state_machine.resume()

func _process(delta: float) -> void:
	if not is_active:
		return
	
	# Process auto/skip mode
	var should_advance: bool = auto_skip.process(
		delta,
		state_machine.current_state,
		current_dialogue_id,
		state_machine.command_index
	)
	
	if should_advance and state_machine.current_state == VNStateMachine.VNState.WAITING:
		advance()
	
	# Auto-advance through non-blocking commands during skip mode
	if auto_skip.skip_mode and state_machine.current_state == VNStateMachine.VNState.COMMAND:
		state_machine.advance()

# === Internal ===

func _execute_event(event: Dictionary) -> void:
	var event_type: String = event.get("type", "")
	match event_type:
		"set_flag":
			if GlobalFlags != null:
				GlobalFlags.set_flag(event.get("key", ""), event.get("value", true))
		"unlock_region":
			EventBus.emit_event("unlock_region", {"region_id": event.get("region_id", "")})
		"start_battle":
			EventBus.emit_event("start_battle", {"enemy_group_id": event.get("enemy_group_id", "")})
		"start_quest":
			EventBus.emit_event("quest_started", {"quest_id": event.get("quest_id", "")})
		_:
			push_warning("VNManager: Unknown event type: %s" % event_type)