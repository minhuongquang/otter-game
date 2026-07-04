class_name PlayerController
extends CharacterBody2D

## Handles player movement and interaction with [Interactable] objects.
##
## Movement uses InputManager for input queries — no direct Input calls.
## Interaction detects nearby [Interactable] Area2D nodes via a child
## InteractionDetector Area2D and calls [method Interactable.interact]
## when the player presses the "interact" action.

# === Exports ===
@export var movement_speed: float = 150.0

# === Private ===
## References to all currently overlapping Interactable nodes.
var _nearby_interactables: Array[Interactable] = []

# === Built-in ===

func _ready() -> void:
	_setup_interaction_detector()

func _physics_process(_delta: float) -> void:
	# Disable movement while VN dialogue is active
	if InputManager.get_active_context() == "visual_novel":
		velocity = Vector2.ZERO
		move_and_slide()
		return
	
	# Movement
	var input_dir: Vector2 = _get_movement_input()
	velocity = input_dir * movement_speed
	move_and_slide()
	
	# Interaction
	if InputManager.is_action_just_pressed("interact"):
		_interact_with_nearest()

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

## Finds or creates the InteractionDetector Area2D child node.
## Configures collision layer/mask so it only detects Interactable areas.
func _setup_interaction_detector() -> void:
	var detector: Area2D = get_node_or_null("InteractionDetector") as Area2D
	if detector == null:
		detector = Area2D.new()
		detector.name = "InteractionDetector"
		
		# Add a circular collision shape for the detection range
		var shape: CollisionShape2D = CollisionShape2D.new()
		var circle: CircleShape2D = CircleShape2D.new()
		circle.radius = 32.0
		shape.shape = circle
		detector.add_child(shape)
		
		add_child(detector)
	
	# Use layer 2 as the "interactable" layer
	# The detector monitors for areas on layer 2.
	# The detector itself does not need to be monitorable by others.
	detector.collision_layer = 0
	detector.collision_mask = 2
	detector.monitorable = false
	detector.monitoring = true
	
	# Connect area signals
	if not detector.area_entered.is_connected(_on_interaction_area_entered):
		detector.area_entered.connect(_on_interaction_area_entered)
	if not detector.area_exited.is_connected(_on_interaction_area_exited):
		detector.area_exited.connect(_on_interaction_area_exited)

## Called when an Area2D enters the InteractionDetector's range.
func _on_interaction_area_entered(area: Area2D) -> void:
	var interactable: Interactable = area as Interactable
	if interactable != null and interactable.can_interact(self):
		_nearby_interactables.append(interactable)

## Called when an Area2D exits the InteractionDetector's range.
func _on_interaction_area_exited(area: Area2D) -> void:
	var interactable: Interactable = area as Interactable
	if interactable != null:
		_nearby_interactables.erase(interactable)

## Calls [method Interactable.interact] on the nearest valid interactable.
func _interact_with_nearest() -> void:
	if _nearby_interactables.is_empty():
		return
	
	# Refresh list: remove invalid (freed or no longer interactable)
	_nearby_interactables = _nearby_interactables.filter(
		func(i: Interactable) -> bool:
			return is_instance_valid(i) and i.can_interact(self)
	)
	
	if _nearby_interactables.is_empty():
		return
	
	# Find the nearest interactable by distance
	var player_pos: Vector2 = global_position
	var nearest: Interactable = _nearby_interactables[0]
	var nearest_dist: float = player_pos.distance_squared_to(nearest.global_position)
	
	for i: Interactable in _nearby_interactables:
		var dist: float = player_pos.distance_squared_to(i.global_position)
		if dist < nearest_dist:
			nearest = i
			nearest_dist = dist
	
	nearest.interact(self)
	
	# If the interactable is now exhausted (one_time), remove from tracking
	if not nearest.can_interact(self):
		_nearby_interactables.erase(nearest)