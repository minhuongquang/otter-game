class_name VNAutoSkip
extends Node

## Manages Auto mode and Skip mode for the Visual Novel.
##
## Auto mode: automatically advances dialogue after a configurable delay.
## Skip mode: rapidly advances through already-read dialogue lines.

signal auto_mode_changed(enabled: bool)
signal skip_mode_changed(enabled: bool)

var auto_mode: bool = false
var skip_mode: bool = false

var auto_delay: float = 3.0  # Seconds to wait before auto-advancing
var skip_speed: float = 0.01  # Seconds between each skip advance

var _auto_timer: float = 0.0
var _skip_timer: float = 0.0

# Track which dialogue IDs and line indices have been read
var _read_lines: Dictionary = {}  # "dialogue_id:line_index" -> true

## Toggle auto mode on/off.
func toggle_auto() -> void:
	auto_mode = not auto_mode
	if auto_mode:
		_auto_timer = 0.0
		skip_mode = false  # Auto and skip are mutually exclusive
		emit_signal("skip_mode_changed", false)
	emit_signal("auto_mode_changed", auto_mode)

## Toggle skip mode on/off.
func toggle_skip() -> void:
	skip_mode = not skip_mode
	if skip_mode:
		_skip_timer = 0.0
		auto_mode = false  # Auto and skip are mutually exclusive
		emit_signal("auto_mode_changed", false)
	emit_signal("skip_mode_changed", skip_mode)

## Enable/disable auto mode directly.
func set_auto_mode(enabled: bool) -> void:
	if enabled != auto_mode:
		if enabled:
			skip_mode = false
			emit_signal("skip_mode_changed", false)
		auto_mode = enabled
		_auto_timer = 0.0
		emit_signal("auto_mode_changed", auto_mode)

## Enable/disable skip mode directly.
func set_skip_mode(enabled: bool) -> void:
	if enabled != skip_mode:
		if enabled:
			auto_mode = false
			emit_signal("auto_mode_changed", false)
		skip_mode = enabled
		_skip_timer = 0.0
		emit_signal("skip_mode_changed", skip_mode)

## Mark a line as read.
func mark_line_read(dialogue_id: String, line_index: int) -> void:
	_read_lines["%s:%d" % [dialogue_id, line_index]] = true

## Check if a line has been read before.
func is_line_read(dialogue_id: String, line_index: int) -> bool:
	return _read_lines.has("%s:%d" % [dialogue_id, line_index])

## Reset read lines tracking.
func clear_read_lines() -> void:
	_read_lines.clear()

## Check if a dialogue ID has any lines read.
func is_dialogue_fully_read(dialogue_id: String) -> bool:
	# Check if at least 90% of lines in this dialogue have been read
	var count: int = 0
	for key in _read_lines.keys():
		if key.begins_with(dialogue_id):
			count += 1
	return count > 0

## Get auto mode advance readiness (0.0-1.0).
func get_auto_progress() -> float:
	if not auto_mode:
		return 0.0
	return clamp(_auto_timer / auto_delay, 0.0, 1.0)

## Reset the auto timer (called after advancing).
func reset_auto_timer() -> void:
	_auto_timer = 0.0

## Process auto/skip timers. Returns true if we should advance.
## dialogue_id and line_index are used for skip mode read detection.
func process(delta: float, current_state: int, dialogue_id: String = "", line_index: int = -1) -> bool:
	var should_advance: bool = false
	
	if auto_mode:
		_auto_timer += delta
		if _auto_timer >= auto_delay:
			_auto_timer = 0.0
			should_advance = true
	
	if skip_mode:
		_skip_timer += delta
		if _skip_timer >= skip_speed:
			_skip_timer = 0.0
			# Check if current line has been read
			if not dialogue_id.is_empty() and line_index >= 0:
				if is_line_read(dialogue_id, line_index):
					should_advance = true
				# If we haven't read it, still skip but at a slower rate
				else:
					_skip_timer -= skip_speed * 2  # Slow down for unread lines
			else:
				should_advance = true
	
	return should_advance

## Serialize for save system.
func serialize() -> Dictionary:
	return {
		"read_lines": _read_lines.duplicate()
	}

## Deserialize from save system.
func deserialize(data: Dictionary) -> void:
	if data.has("read_lines"):
		_read_lines = data["read_lines"].duplicate()