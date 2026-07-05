class_name TestRoom
extends Node2D

## Simple test room for development sandbox.
## Provides player movement testing and Escape-to-menu navigation.

# === Constants ===
const MAIN_MENU_PATH: String = "res://scenes/ui/main_menu.tscn"

# === Built-in ===
func _ready() -> void:
	InputManager.push_context("gameplay")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_menu") or event.is_action_pressed("ui_cancel"):
		SceneManager.change_scene(MAIN_MENU_PATH)