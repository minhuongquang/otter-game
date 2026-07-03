class_name PlayerController
extends CharacterBody2D

## Handles player movement using InputManager for input queries.
## Movement is read-only from InputManager — no direct Input calls.

# === Exports ===
@export var movement_speed: float = 150.0

# === Built-in ===

func _physics_process(_delta: float) -> void:
	var input_dir: Vector2 = _get_movement_input()
	velocity = input_dir * movement_speed
	move_and_slide()

# === Private Methods ===

## Returns a normalized input vector from movement actions.
## Reads input exclusively through InputManager.
func _get_movement_input() -> Vector2:
	var dir: Vector2 = Vector2.ZERO

	if InputManager.is_action_pressed("move_left"):
		dir.x -= 1.0
	if InputManager.is_action_pressed("move_right"):
		dir.x += 1.0
	if InputManager.is_action_pressed("move_up"):
		dir.y -= 1.0
	if InputManager.is_action_pressed("move_down"):
		dir.y += 1.0

	return dir.normalized()