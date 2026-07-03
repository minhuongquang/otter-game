extends Node

## Handle scene transitions, loading screens, fade effects, and scene lifecycle.
## Centralizes all scene changes so that autosave, audio transitions, and UI cleanup happen automatically.

# === Signals ===
signal scene_loading_started(from_path: String, to_path: String)
signal scene_loaded(scene_path: String)
signal scene_changed(from_path: String, to_path: String)

# === Private ===
var _current_scene: Node = null
var _current_scene_path: String = ""
var _is_transitioning: bool = false
var _transition_overlay: ColorRect = null
var _pending_data: Dictionary = {}

# === Built-in ===
func _ready() -> void:
	var root: Window = get_tree().root
	_current_scene = root.get_child(root.get_child_count() - 1)
	if _current_scene:
		_current_scene_path = _current_scene.scene_file_path

# === Public Methods ===

func change_scene(scene_path: String, data: Dictionary = {}) -> void:
	if _is_transitioning:
		push_warning("SceneManager: Already transitioning, ignoring: %s" % scene_path)
		return
	
	_is_transitioning = true
	var from_path: String = _current_scene_path
	_pending_data = data.duplicate()
	
	scene_loading_started.emit(from_path, scene_path)
	EventBus.emit_event("scene_loading_started", {"from": from_path, "to": scene_path, "data": data})
	
	await fade_to_black(0.3)
	
	_cleanup_current_scene()
	
	var error := get_tree().change_scene_to_file(scene_path)
	if error != OK:
		push_error("SceneManager: Failed to load scene: %s (error %d)" % [scene_path, error])
		_is_transitioning = false
		_pending_data = {}
		return
	
	_update_current_scene()
	
	await fade_from_black(0.3)
	
	_is_transitioning = false
	_pending_data = {}
	scene_loaded.emit(scene_path)
	scene_changed.emit(from_path, scene_path)
	EventBus.emit_event("scene_changed", {"from": from_path, "to": scene_path})

func change_scene_with_overlay(scene_path: String, overlay_path: String, data: Dictionary = {}) -> void:
	change_scene(scene_path, data)
	if _current_scene:
		var overlay_scene: PackedScene = load(overlay_path)
		if overlay_scene:
			var overlay: Node = overlay_scene.instantiate()
			_current_scene.add_child(overlay)

func reload_current_scene() -> void:
	if _current_scene_path:
		change_scene(_current_scene_path)

func get_current_scene() -> Node:
	return _current_scene

func get_current_scene_path() -> String:
	return _current_scene_path

func get_pending_data() -> Dictionary:
	return _pending_data.duplicate()

func fade_to_black(duration: float = 0.3) -> Signal:
	_ensure_overlay()
	var tween: Tween = create_tween()
	tween.tween_property(_transition_overlay, "color", Color.BLACK, duration)
	return tween.finished

func fade_from_black(duration: float = 0.3) -> Signal:
	_ensure_overlay()
	var tween: Tween = create_tween()
	tween.tween_property(_transition_overlay, "color", Color.TRANSPARENT, duration)
	return tween.finished

# === Private Methods ===

func _ensure_overlay() -> void:
	if _transition_overlay == null or not is_instance_valid(_transition_overlay):
		_transition_overlay = ColorRect.new()
		_transition_overlay.color = Color.TRANSPARENT
		_transition_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_transition_overlay.size = Vector2(
			ProjectSettings.get_setting("display/window/size/viewport_width", 1920),
			ProjectSettings.get_setting("display/window/size/viewport_height", 1080)
		)
		_transition_overlay.show_behind_parent = true
		add_child(_transition_overlay)

func _cleanup_current_scene() -> void:
	if _current_scene:
		if _current_scene.has_method("on_scene_exit"):
			_current_scene.call("on_scene_exit")
		_current_scene.queue_free()
		_current_scene = null
		_current_scene_path = ""

func _update_current_scene() -> void:
	var root: Window = get_tree().root
	_current_scene = root.get_child(root.get_child_count() - 1)
	if _current_scene:
		_current_scene_path = _current_scene.scene_file_path
		if _current_scene.has_method("on_scene_enter"):
			_current_scene.call("on_scene_enter", [_pending_data])