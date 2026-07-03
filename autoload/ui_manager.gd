extends Node

## Manage UI screen stack, HUD display, overlays, notifications, and transitions.
## UI lives in CanvasLayer nodes. Screens are stacked; only the top screen receives input.

# === Constants ===
const LAYER_HUD: int = 10
const LAYER_SCREENS: int = 20
const LAYER_DIALOGS: int = 30
const LAYER_TOOLTIPS: int = 40

# === Signals ===
signal screen_opened(screen_id: String)
signal screen_closed(screen_id: String)
signal game_paused()
signal game_resumed()

# === Exports ===
@export var screen_registry: Dictionary = {
	"main_menu": "res://scenes/ui/main_menu.tscn",
	"save_screen": "res://scenes/ui/save_screen.tscn",
	"inventory": "res://scenes/ui/inventory_screen.tscn",
	"quest_log": "res://scenes/ui/quest_log.tscn",
	"settings": "res://scenes/ui/settings_screen.tscn",
	"pause_menu": "res://scenes/ui/pause_menu.tscn",
	"dialogue_box": "res://scenes/ui/dialogue_box.tscn"
}

# === Private ===
var _ui_root: CanvasLayer = null
var _hud: Node = null
var _screen_stack: Array[String] = []
var _screen_instances: Dictionary = {}  # screen_id -> Node
var _tooltip: Control = null

# === Built-in ===
func _ready() -> void:
	_ui_root = CanvasLayer.new()
	_ui_root.layer = LAYER_HUD
	_ui_root.name = "UIRoot"
	add_child(_ui_root)

# === Public Methods ===

func open_screen(screen_id: String, data: Dictionary = {}) -> void:
	if _screen_instances.has(screen_id):
		push_warning("UIManager: Screen already open: %s" % screen_id)
		return
	
	if not screen_registry.has(screen_id):
		push_error("UIManager: Unknown screen: %s" % screen_id)
		return
	
	var scene_path: String = screen_registry[screen_id]
	var scene: PackedScene = load(scene_path)
	if scene == null:
		push_error("UIManager: Cannot load screen scene: %s" % scene_path)
		return
	
	var instance: Node = scene.instantiate()
	instance.name = screen_id
	_ui_root.add_child(instance)
	_screen_instances[screen_id] = instance
	_screen_stack.append(screen_id)
	
	if instance.has_method("on_open"):
		instance.call("on_open", data)
	
	screen_opened.emit(screen_id)
	EventBus.emit_event("screen_opened", {"screen_id": screen_id})

func close_screen(screen_id: String) -> void:
	if not _screen_instances.has(screen_id):
		return
	
	var instance: Node = _screen_instances[screen_id]
	_screen_instances.erase(screen_id)
	_screen_stack.erase(screen_id)
	
	if instance.has_method("on_close"):
		instance.call("on_close")
	
	instance.queue_free()
	screen_closed.emit(screen_id)
	EventBus.emit_event("screen_closed", {"screen_id": screen_id})

func close_top_screen() -> void:
	if _screen_stack.is_empty():
		return
	var top: String = _screen_stack.back()
	close_screen(top)

func close_all_screens() -> void:
	while not _screen_stack.is_empty():
		close_screen(_screen_stack.back())

func is_screen_open(screen_id: String) -> bool:
	return _screen_instances.has(screen_id)

func get_open_screens() -> Array[String]:
	return _screen_stack.duplicate()

func show_hud() -> void:
	if _hud == null:
		var scene: PackedScene = load("res://scenes/ui/hud.tscn")
		if scene:
			_hud = scene.instantiate()
			_hud.name = "HUD"
			_ui_root.add_child(_hud)

func hide_hud() -> void:
	if _hud:
		_hud.queue_free()
		_hud = null

func show_notification(text: String, duration: float = 2.0) -> void:
	var label: Label = Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_ui_root.add_child(label)
	
	var tween: Tween = create_tween()
	tween.tween_property(label, "modulate:a", 1.0, 0.2)
	tween.tween_interval(duration)
	tween.tween_property(label, "modulate:a", 0.0, 0.5)
	tween.tween_callback(label.queue_free)

func show_pause_menu() -> void:
	if _screen_stack.is_empty() or _screen_stack.back() != "pause_menu":
		open_screen("pause_menu")
		game_paused.emit()
		EventBus.emit_event("game_paused", {})

func hide_pause_menu() -> void:
	if _screen_stack.back() == "pause_menu":
		close_top_screen()
		game_resumed.emit()
		EventBus.emit_event("game_resumed", {})
