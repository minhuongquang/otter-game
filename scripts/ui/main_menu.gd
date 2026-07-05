class_name MainMenu
extends Control

## Main menu screen with New Game, Load Game, Settings, and Quit options.

# === Signals ===
signal new_game_requested
signal load_game_requested
signal settings_requested
signal quit_requested

# === Constants ===
const FIRST_VN_PATH: String = "res://scenes/ui/vn/visual_novel.tscn"
const TEST_ROOM_PATH: String = "res://scenes/test/test_room.tscn"

# === @onready ===
@onready var first_button: Button = $CenterContainer/VBoxContainer/ButtonContainer/NewGameButton

# === Built-in ===
func _ready() -> void:
	UIManager.show_notification("Welcome to SariaMod")
	first_button.grab_focus()

func on_scene_enter() -> void:
	UIManager.show_hud()

# === Button Callbacks ===
func _on_new_game_pressed() -> void:
	GlobalFlags.clear_all_flags()
	EventBus.emit_event("game_started", {})
	SceneManager.change_scene(FIRST_VN_PATH)

func _on_load_game_pressed() -> void:
	UIManager.show_notification("Load Game is not available yet.")

func _on_settings_pressed() -> void:
	UIManager.open_screen("settings")

func _on_test_room_pressed() -> void:
	SceneManager.change_scene(TEST_ROOM_PATH)

func _on_quit_pressed() -> void:
	if OS.has_feature("editor"):
		print("MainMenu: Quit requested — running in editor, cannot quit.")
	else:
		get_tree().quit()
