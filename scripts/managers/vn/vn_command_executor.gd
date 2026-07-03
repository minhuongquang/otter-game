class_name VNCommandExecutor
extends Node

## Dispatches VNCommand instances to registered handler functions.
## Uses the Command Pattern: each command type maps to a handler callback.
## Custom commands can be registered by any system at runtime.

signal command_executed(command_type: String, success: bool)
signal blocking_command_finished()

# Maps command_type string -> Callable handler
var _handlers: Dictionary = {}
var _active_blocking_count: int = 0

# Reference to the state machine for control flow (branch, jump)
var _state_machine: VNStateMachine = null
var _variable_store: VNVariableStore = null

## Initialize with required dependencies.
func initialize(state_machine: VNStateMachine, variable_store: VNVariableStore) -> void:
	_state_machine = state_machine
	_variable_store = variable_store
	_register_default_handlers()

## Register a custom command handler.
## handler(command: VNCommand, executor: VNCommandExecutor) -> bool
## Returns true if blocking (executor waits for completion signal), false otherwise.
func register_handler(command_type: String, handler: Callable) -> void:
	_handlers[command_type] = handler

## Execute a single command.
## Returns true if the command is blocking, false otherwise.
func execute(command: VNCommand) -> bool:
	if _handlers.has(command.command_type):
		var handler: Callable = _handlers[command.command_type]
		if handler.is_valid():
			var is_blocking: bool = handler.call(command, self)
			emit_signal("command_executed", command.command_type, true)
			
			if is_blocking:
				_active_blocking_count += 1
			
			return is_blocking
		else:
			push_warning("VNCommandExecutor: Invalid handler for '%s'" % command.command_type)
	else:
		push_warning("VNCommandExecutor: No handler registered for '%s'" % command.command_type)
		emit_signal("command_executed", command.command_type, false)
	
	return false

## Called by blocking command handlers when they finish execution.
func on_blocking_command_finished() -> void:
	if _active_blocking_count > 0:
		_active_blocking_count -= 1
	emit_signal("blocking_command_finished")

## Check if any blocking command is still executing.
func has_active_blocking() -> bool:
	return _active_blocking_count > 0

# === Default Handlers ===

func _register_default_handlers() -> void:
	register_handler("dialogue_line", _handle_dialogue_line)
	register_handler("show_character", _handle_show_character)
	register_handler("hide_character", _handle_hide_character)
	register_handler("change_expression", _handle_change_expression)
	register_handler("background", _handle_background)
	register_handler("play_bgm", _handle_play_bgm)
	register_handler("stop_bgm", _handle_stop_bgm)
	register_handler("play_sfx", _handle_play_sfx)
	register_handler("shake_camera", _handle_shake_camera)
	register_handler("fade", _handle_fade)
	register_handler("give_item", _handle_give_item)
	register_handler("start_battle", _handle_start_battle)
	register_handler("unlock_region", _handle_unlock_region)
	register_handler("start_cutscene", _handle_start_cutscene)
	register_handler("set_flag", _handle_set_flag)
	register_handler("set_variable", _handle_set_variable)
	register_handler("branch", _handle_branch)
	register_handler("choice", _handle_choice)
	register_handler("animation", _handle_animation)
	register_handler("wait", _handle_wait)

# === Handler Implementations ===
# Each handler returns true if blocking, false if not.
# Blocking handlers must call on_blocking_command_finished() when done.

func _handle_dialogue_line(command: VNCommand, executor: VNCommandExecutor) -> bool:
	# Dialogue lines are handled by the VNManager/state machine directly
	# The executor just passes through; the UI layer handles display
	return false

func _handle_show_character(command: VNCommand, executor: VNCommandExecutor) -> bool:
	var cmd: VNCmdShowCharacter = command as VNCmdShowCharacter
	if cmd == null:
		return false
	
	# Emit event for VN UI to handle asynchronously
	EventBus.emit_event("vn_show_character", {
		"character_id": cmd.character_id,
		"position": cmd.position,
		"animation": cmd.animation
	})
	
	# Non-blocking: UI handles animation independently
	return false

func _handle_hide_character(command: VNCommand, executor: VNCommandExecutor) -> bool:
	var cmd: VNCmdHideCharacter = command as VNCmdHideCharacter
	if cmd == null:
		return false
	
	# Emit event for VN UI to handle asynchronously
	EventBus.emit_event("vn_hide_character", {
		"character_id": cmd.character_id,
		"animation": cmd.animation
	})
	
	# Non-blocking: UI handles animation independently
	return false

func _handle_change_expression(command: VNCommand, executor: VNCommandExecutor) -> bool:
	var cmd: VNCmdChangeExpression = command as VNCmdChangeExpression
	if cmd == null:
		return false
	
	EventBus.emit_event("vn_change_expression", {
		"character_id": cmd.character_id,
		"emotion": cmd.emotion
	})
	
	return false

func _handle_background(command: VNCommand, executor: VNCommandExecutor) -> bool:
	var cmd: VNCmdBackground = command as VNCmdBackground
	if cmd == null:
		return false
	
	EventBus.emit_event("vn_change_background", {
		"texture_path": cmd.texture_path,
		"transition": cmd.transition,
		"duration": cmd.duration
	})
	
	# Non-blocking: UI handles transition independently
	return false

func _handle_play_bgm(command: VNCommand, executor: VNCommandExecutor) -> bool:
	var cmd: VNCmdPlayBGM = command as VNCmdPlayBGM
	if cmd == null:
		return false
	
	EventBus.emit_event("vn_play_bgm", {
		"audio_path": cmd.audio_path,
		"fade_in": cmd.fade_in
	})
	
	return false

func _handle_stop_bgm(command: VNCommand, executor: VNCommandExecutor) -> bool:
	var cmd: VNCmdStopBGM = command as VNCmdStopBGM
	if cmd == null:
		return false
	
	EventBus.emit_event("vn_stop_bgm", {
		"fade_out": cmd.fade_out
	})
	
	return false

func _handle_play_sfx(command: VNCommand, executor: VNCommandExecutor) -> bool:
	var cmd: VNCmdPlaySFX = command as VNCmdPlaySFX
	if cmd == null:
		return false
	
	EventBus.emit_event("vn_play_sfx", {
		"audio_path": cmd.audio_path,
		"volume": cmd.volume
	})
	
	return false

func _handle_shake_camera(command: VNCommand, executor: VNCommandExecutor) -> bool:
	var cmd: VNCmdShakeCamera = command as VNCmdShakeCamera
	if cmd == null:
		return false
	
	EventBus.emit_event("vn_shake_camera", {
		"intensity": cmd.intensity,
		"duration": cmd.duration
	})
	
	# Non-blocking: UI handles shake independently
	return false

func _handle_fade(command: VNCommand, executor: VNCommandExecutor) -> bool:
	var cmd: VNCmdFade = command as VNCmdFade
	if cmd == null:
		return false
	
	EventBus.emit_event("vn_fade", {
		"target_color": cmd.target_color,
		"custom_color": cmd.custom_color,
		"duration": cmd.duration
	})
	
	# Non-blocking: UI handles fade independently
	return false

func _handle_give_item(command: VNCommand, executor: VNCommandExecutor) -> bool:
	var cmd: VNCmdGiveItem = command as VNCmdGiveItem
	if cmd == null:
		return false
	
	EventBus.emit_event("vn_give_item", {
		"item_id": cmd.item_id,
		"quantity": cmd.quantity
	})
	
	return false

func _handle_start_battle(command: VNCommand, executor: VNCommandExecutor) -> bool:
	var cmd: VNCmdStartBattle = command as VNCmdStartBattle
	if cmd == null:
		return false
	
	EventBus.emit_event("vn_start_battle", {
		"enemy_group_id": cmd.enemy_group_id
	})
	
	# SceneManager will handle the transition; VN is suspended
	return false

func _handle_unlock_region(command: VNCommand, executor: VNCommandExecutor) -> bool:
	var cmd: VNCmdUnlockRegion = command as VNCmdUnlockRegion
	if cmd == null:
		return false
	
	EventBus.emit_event("vn_unlock_region", {
		"region_id": cmd.region_id
	})
	
	return false

func _handle_start_cutscene(command: VNCommand, executor: VNCommandExecutor) -> bool:
	var cmd: VNCmdStartCutscene = command as VNCmdStartCutscene
	if cmd == null:
		return false
	
	EventBus.emit_event("vn_start_cutscene", {
		"cutscene_id": cmd.cutscene_id
	})
	
	# Non-blocking; SceneManager handles the transition
	return false

func _handle_set_flag(command: VNCommand, executor: VNCommandExecutor) -> bool:
	var cmd: VNCmdSetFlag = command as VNCmdSetFlag
	if cmd == null:
		return false
	
	if GlobalFlags != null:
		GlobalFlags.set_flag(cmd.flag_key, cmd.flag_value)
	
	return false

func _handle_set_variable(command: VNCommand, executor: VNCommandExecutor) -> bool:
	var cmd: VNCmdSetVariable = command as VNCmdSetVariable
	if cmd == null:
		return false
	
	if _variable_store != null:
		_variable_store.set_variable(cmd.var_key, cmd.operator, cmd.var_value)
	
	return false

func _handle_branch(command: VNCommand, executor: VNCommandExecutor) -> bool:
	var cmd: VNCmdBranch = command as VNCmdBranch
	if cmd == null:
		return false
	
	var condition_met: bool = false
	
	if _variable_store != null:
		condition_met = _variable_store.evaluate_condition(cmd.condition_expression)
	else:
		# If no variable store, treat "true" as the only truthy condition
		condition_met = (cmd.condition_expression.strip_edges() == "true")
	
	if condition_met and _state_machine != null and not cmd.target_label.is_empty():
		_state_machine.jump_to_label(cmd.target_label)
		return false  # State machine handles the flow
	
	# Condition not met: advance to next command
	return false

func _handle_choice(command: VNCommand, executor: VNCommandExecutor) -> bool:
	# Choice handling is done entirely by the state machine + UI
	# The executor doesn't need to do anything here
	return false  # State machine handles the blocking via CHOICE state

func _handle_animation(command: VNCommand, executor: VNCommandExecutor) -> bool:
	var cmd: VNCmdAnimation = command as VNCmdAnimation
	if cmd == null:
		return false
	
	EventBus.emit_event("vn_animation", {
		"target": cmd.target,
		"animation_id": cmd.animation_id,
		"params": cmd.params
	})
	
	# Non-blocking: UI handles animation independently
	return false

func _handle_wait(command: VNCommand, executor: VNCommandExecutor) -> bool:
	var cmd: VNCmdWait = command as VNCmdWait
	if cmd == null:
		return false
	
	# Start a timer and wait
	var timer := get_tree().create_timer(cmd.duration)
	timer.timeout.connect(_on_wait_timer_finished.bind(executor))
	
	return true  # Blocking

func _on_wait_timer_finished(executor: VNCommandExecutor) -> void:
	executor.on_blocking_command_finished()