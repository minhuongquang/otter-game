extends Node2D

## Controller for a building interior scene.
## Generic template that handles NPC spawning, exits, and building-specific logic.

# === Exports ===
@export var navigation_manager: NavigationManager = null
@export var building_id: String = ""

# === Node References ===
@onready var background: TextureRect = $Background
@onready var npc_container: Node = $Interior/NPCContainer
@onready var player_spawn: Marker2D = $Interior/PlayerSpawn
@onready var exit_door: Area2D = $ExitDoor
@onready var shop_panel: Control = $UI/ShopPanel
@onready var inn_panel: Control = $UI/InnPanel

# === Private ===
var _building: BuildingEntry = null
var _region_id: String = ""

# === Built-in ===
func _ready() -> void:
	_setup_navigation_manager()
	_load_building_data()
	_spawn_npcs()
	_connect_signals()

func _setup_navigation_manager() -> void:
	if navigation_manager == null:
		navigation_manager = NavigationManager.new()
		add_child(navigation_manager)

func _load_building_data() -> void:
	_region_id = navigation_manager.current_region_id
	_building = navigation_manager.get_current_building()
	
	if _building == null:
		push_error("BuildingInterior: No current building set in NavigationManager")
		return
	
	building_id = _building.building_id
	
	# Set background if available (would be set via scene or export)
	var bg_texture: Texture2D = _get_background_for_building(_building.building_type)
	if bg_texture:
		background.texture = bg_texture

func _spawn_npcs() -> void:
	if _building == null or _building.npc_ids.is_empty():
		return
	
	for npc_id: String in _building.npc_ids:
		_spawn_npc(npc_id)

func _spawn_npc(npc_id: String) -> void:
	var character: CharacterResource = Database.get_character(npc_id) as CharacterResource
	if character == null:
		return
	
	# NPC scene would be instantiated here (NPC.tscn)
	# For now, create a placeholder
	var npc: Area2D = Area2D.new()
	npc.name = "NPC_" + npc_id
	
	var sprite: Sprite2D = Sprite2D.new()
	if character.sprite:
		sprite.texture = character.sprite
	sprite.position = _get_spawn_position_for_npc(npc_id)
	npc.add_child(sprite)
	
	# Add interaction area
	var interaction: CollisionShape2D = CollisionShape2D.new()
	var shape: RectangleShape2D = RectangleShape2D.new()
	shape.size = Vector2(32, 48)
	interaction.shape = shape
	npc.add_child(interaction)
	
	# Add label
	var label: Label = Label.new()
	label.text = character.display_name
	label.position = Vector2(-40, -24)
	label.size = Vector2(80, 20)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	npc.add_child(label)
	
	npc_container.add_child(npc)

func _connect_signals() -> void:
	if exit_door:
		exit_door.body_entered.connect(_on_exit_door_entered)

# === Signal Handlers ===

func _on_exit_door_entered(body: Node) -> void:
	if body.is_in_group("player"):
		navigation_manager.exit_building()
		_transition_to_region_hub()

func _on_interaction_area_entered(npc: Area2D) -> void:
	# Show interaction prompt
	EventBus.emit_event("show_interaction_prompt", {
		"npc_id": npc.name.trim_prefix("NPC_")
	})

# === Private Methods ===

func _transition_to_region_hub() -> void:
	SceneManager.change_scene("res://scenes/world/region_hub.tscn", {
		"region_id": _region_id
	})

func _get_background_for_building(building_type: BuildingType.Type) -> Texture2D:
	# Would load from a resource or asset path based on type
	# Placeholder — returns null, background is set in scene
	return null

func _get_spawn_position_for_npc(_npc_id: String) -> Vector2:
	# Would load from map data
	# Placeholder — NPCs would be positioned via the scene
	return Vector2(200 + randi() % 400, 300)