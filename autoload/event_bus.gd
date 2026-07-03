extends Node

## Global event dispatch system.
## Any module can emit or listen to events without direct references.
##
## Usage:
##   EventBus.emit_event("battle_started", {"enemy_group": "goblin_pack"})
##   EventBus.listen("battle_started", _on_battle_started)
##   EventBus.unlisten("battle_started", _on_battle_started)

# === Signals ===
signal event_emitted(event_name: String, data: Dictionary)

# === Private ===
var _listeners: Dictionary = {}  # event_name -> Array[Callable]

# === Public Methods ===

## Emit an event to all registered listeners.
func emit_event(event_name: String, data: Dictionary = {}) -> void:
	event_emitted.emit(event_name, data)
	if _listeners.has(event_name):
		var callbacks: Array = _listeners[event_name]
		for callback: Callable in callbacks:
			if callback.is_valid():
				callback.call(data)

## Register a listener callback for an event.
func listen(event_name: String, callback: Callable) -> void:
	if not _listeners.has(event_name):
		_listeners[event_name] = []
	_listeners[event_name].append(callback)

## Remove a listener callback.
func unlisten(event_name: String, callback: Callable) -> void:
	if _listeners.has(event_name):
		_listeners[event_name].erase(callback)
		if _listeners[event_name].is_empty():
			_listeners.erase(event_name)

## Check if an event has any listeners.
func has_listeners(event_name: String) -> bool:
	return _listeners.has(event_name) and not _listeners[event_name].is_empty()

## Remove all listeners for an event.
func clear_event(event_name: String) -> void:
	_listeners.erase(event_name)

## Remove all listeners for all events.
func clear_all() -> void:
	_listeners.clear()
