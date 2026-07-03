class_name VNTypewriter
extends Node

## Manages the typewriter text effect for dialogue display.
## Reveals text character by character at a configurable speed.
## Supports BBCode rich text tags (skips tag content in timing).

signal finished()
signal character_revealed(character_index: int, total_characters: int)

var speed: float = 0.05  # Seconds per character
var is_typing: bool = false
var is_paused: bool = false

var _text: String = ""
var _label: RichTextLabel = null
var _current_index: int = 0
var _timer: float = 0.0
var _tag_depth: int = 0  # Track BBCode nesting depth

## Start typing text into the given RichTextLabel.
func start_display(text: String, label: RichTextLabel) -> void:
	_text = text
	_label = label
	_current_index = 1  # Start revealing from first character
	_timer = 0.0
	is_typing = true
	is_paused = false
	
	# Set full text but with visible_chars control
	_label.text = text
	_label.visible_characters = 1

## Skip the typewriter effect to show all text instantly.
func skip_to_end() -> void:
	if _label != null and is_typing:
		_label.visible_characters = -1  # -1 = show all
		is_typing = false
		emit_signal("finished")

## Pause the typewriter effect.
func pause() -> void:
	is_paused = true

## Resume the typewriter effect.
func resume() -> void:
	is_paused = false

## Change the typewriter speed.
func set_speed(new_speed: float) -> void:
	speed = max(0.01, new_speed)

func _process(delta: float) -> void:
	if not is_typing or is_paused or _label == null:
		return
	
	_timer += delta
	
	while _timer >= speed and _current_index <= _text.length():
		_timer -= speed
		
		# Skip BBCode tags
		var char: String = ""
		if _current_index <= _text.length():
			char = _text[_current_index - 1]
		
		# Track tag depth to skip entire tag content for timing
		if char == "[":
			_tag_depth += 1
		elif char == "]":
			_tag_depth -= 1
		
		if _tag_depth <= 0:
			_tag_depth = 0
			# Only emit for visible characters (not inside tags)
			if _label != null:
				_label.visible_characters = _current_index
				emit_signal("character_revealed", _current_index, _text.length())
		
		_current_index += 1
	
	# Check if typing is complete
	if _current_index > _text.length() and is_typing:
		if _label != null:
			_label.visible_characters = -1  # Show all remaining
		is_typing = false
		emit_signal("finished")

## Get the current progress as a float 0.0-1.0.
func get_progress() -> float:
	if _text.is_empty():
		return 1.0
	return float(_current_index) / float(_text.length())