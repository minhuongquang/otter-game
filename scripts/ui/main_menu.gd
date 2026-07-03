class_name MainMenu
extends Control

## Main menu screen with New Game, Load Game, Settings, and Quit options.

# === Signals ===
signal new_game_requested
signal load_game_requested
signal settings_requested
signal quit_requested

# === Constants ===
const FIRST_VN_PATH: String = "res://scenes/world/visual_novel.tscn"

# === Built-in ===
func _ready() -> void:
	EventBus.listen("game_loaded", _on_game_loaded)
	UIManager.show_notification("Welcome to SariaMod")

func on_scene_enter() -> void:
	UIManager.show_hud()

# === Button Callbacks ===
func _on_new_game_pressed() -> void:
	if SaveManager.slot_exists(0):
		# Confirm overwrite if autosave exists
		UIManager.open_screen("confirmation", {
			"title": "New Game",
			"message": "Starting a new game will overwrite your autosave. Continue?",
			"confirm_callback": _start_new_game
		})
	else:
		_start_new_game()

func _on_load_game_pressed() -> void:
	UIManager.open_screen("save_screen", {"mode": "load"})

func _on_settings_pressed() -> void:
	UIManager.open_screen("settings")

func _on_quit_pressed() -> void:
	get_tree().quit()

# === Private Methods ===
func _start_new_game() -> void:
	EventBus.emit_event("game_started", {})
	SceneManager.change_scene(FIRST_VN_PATH)

func _on_game_loaded(data: Dictionary) -> void:
	# SceneManager handles transition via SaveManager
	pass
