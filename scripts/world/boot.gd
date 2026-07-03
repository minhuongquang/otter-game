class_name Boot
extends Node

## Boot sequence: initializes systems, shows splash, transitions to main menu.

# === Constants ===
const MAIN_MENU_PATH: String = "res://scenes/ui/main_menu.tscn"
const SPLASH_DURATION: float = 1.0

# === Exports ===
@export var show_splash: bool = true

# === Built-in ===
func _ready() -> void:
	_apply_saved_settings()
	EventBus.listen("game_loaded", _on_save_loaded)
	
	if show_splash:
		await _show_splash()
	
	SceneManager.change_scene(MAIN_MENU_PATH)

# === Private Methods ===

func _apply_saved_settings() -> void:
	# Audio settings
	var volume: float = _load_setting("audio/master_volume", 0.0)
	AudioManager.set_bus_volume("Master", volume)
	
	# Input bindings
	InputManager.load_keybindings()

func _show_splash() -> void:
	if not has_node("SplashTexture"):
		return
	
	var splash: TextureRect = $SplashTexture
	splash.modulate = Color.TRANSPARENT
	var tween: Tween = create_tween()
	tween.tween_property(splash, "modulate", Color.WHITE, 0.3)
	tween.tween_interval(SPLASH_DURATION)
	tween.tween_property(splash, "modulate", Color.TRANSPARENT, 0.3)
	await tween.finished

func _load_setting(key: String, default_value: Variant) -> Variant:
	var config: ConfigFile = ConfigFile.new()
	var error := config.load("user://settings.cfg")
	if error == OK:
		return config.get_value("settings", key, default_value)
	return default_value

func _on_save_loaded(data: Dictionary) -> void:
	# Called when SaveManager loads a save during boot (Load Game from menu)
	if data.has("current_scene") and data["current_scene"] != "":
		SceneManager.change_scene(data["current_scene"])
