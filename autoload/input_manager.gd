extends Node

## Manage input mappings, controller support, key rebinding, and input contexts.

# === Constants ===
const CONTEXT_GLOBAL: String = "global"
const CONTEXT_EXPLORATION: String = "exploration"
const CONTEXT_BATTLE: String = "battle"
const CONTEXT_VISUAL_NOVEL: String = "visual_novel"
const CONTEXT_MENU: String = "menu"
const SETTINGS_PATH: String = "user://input_bindings.cfg"

# === Signals ===
signal input_rebound(action: String)
signal control_scheme_changed(scheme: String)

# === Private ===
var _context_stack: Array[String] = [CONTEXT_GLOBAL]
var _default_bindings: Dictionary = {}

# === Public Methods ===

func push_context(context: String) -> void:
	_context_stack.push_back(context)

func pop_context() -> void:
	if _context_stack.size() > 1:
		_context_stack.pop_back()

func get_active_context() -> String:
	return _context_stack.back()

func rebind_action(action: String, event: InputEvent) -> bool:
	if not InputMap.has_action(action):
		push_error("InputManager: Unknown action: %s" % action)
		return false
	
	InputMap.action_erase_events(action)
	InputMap.action_add_event(action, event)
	input_rebound.emit(action)
	EventBus.emit_event("input_rebound", {"action": action})
	return true

func reset_action(action: String) -> void:
	if not InputMap.has_action(action):
		return
	InputMap.action_erase_events(action)
	if _default_bindings.has(action):
		for event: InputEvent in _default_bindings[action]:
			InputMap.action_add_event(action, event)

func reset_all_to_defaults() -> void:
	for action: String in _default_bindings.keys():
		reset_action(action)
	save_keybindings()

func get_action_bindings(action: String) -> Array[InputEvent]:
	if InputMap.has_action(action):
		return InputMap.action_get_events(action)
	return []

func is_controller_connected() -> bool:
	return Input.get_connected_joypads().size() > 0

func get_current_scheme() -> String:
	if is_controller_connected():
		return "controller"
	return "keyboard"

func load_keybindings() -> void:
	if not FileAccess.file_exists(SETTINGS_PATH):
		return
	var file: FileAccess = FileAccess.open(SETTINGS_PATH, FileAccess.READ)
	if file == null:
		return
	var json_string: String = file.get_as_text()
	file.close()
	
	var json: JSON = JSON.new()
	if json.parse(json_string) != OK:
		return
	
	var data: Dictionary = json.data as Dictionary
	for action: String in data.keys():
		var events_data: Array = data[action]
		if InputMap.has_action(action):
			InputMap.action_erase_events(action)
			for event_data: Dictionary in events_data:
				var event: InputEvent = _dict_to_event(event_data)
				if event:
					InputMap.action_add_event(action, event)

func save_keybindings() -> void:
	var data: Dictionary = {}
	for action: String in InputMap.get_actions():
		if action.begins_with("ui_"):
			continue
		var events: Array[InputEvent] = InputMap.action_get_events(action)
		if events.is_empty():
			continue
		var events_data: Array = []
		for event: InputEvent in events:
			events_data.append(_event_to_dict(event))
		data[action] = events_data
	
	var file: FileAccess = FileAccess.open(SETTINGS_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))
		file.close()

# === Private Methods ===

func _event_to_dict(event: InputEvent) -> Dictionary:
	var result: Dictionary = {"type": event.get_class()}
	if event is InputEventKey:
		result["keycode"] = event.keycode
		result["modifier_keys"] = {
			"alt": event.alt_pressed,
			"shift": event.shift_pressed,
			"ctrl": event.ctrl_pressed,
			"meta": event.meta_pressed
		}
	elif event is InputEventJoypadButton:
		result["button_index"] = event.button_index
		result["device"] = event.device
	return result

func _dict_to_event(data: Dictionary) -> InputEvent:
	var type: String = data.get("type", "")
	if type == "InputEventKey":
		var event: InputEventKey = InputEventKey.new()
		event.keycode = data.get("keycode", 0)
		return event
	elif type == "InputEventJoypadButton":
		var event: InputEventJoypadButton = InputEventJoypadButton.new()
		event.button_index = data.get("button_index", 0)
		event.device = data.get("device", 0)
		return event
	return null
