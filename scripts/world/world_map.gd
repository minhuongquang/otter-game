extends CanvasLayer

## Controller for the WorldMap scene.
## Displays region markers, handles selection, and manages navigation state.

# === Signals ===
signal region_entered(region_id: String)

# === Exports ===
@export var navigation_manager: NavigationManager = null

# === Node References ===
@onready var region_container: Node = $MapContainer
@onready var info_panel: Control = $RegionInfoPanel
@onready var region_name_label: Label = $RegionInfoPanel/RegionName
@onready var description_label: Label = $RegionInfoPanel/Description
@onready var locked_label: Label = $RegionInfoPanel/LockedLabel
@onready var enter_button: Button = $RegionInfoPanel/EnterButton
@onready var back_button: Button = $BackButton
@onready var location_label: Label = $NavigationInfo/CurrentLocation

# === Private ===
var _selected_region_id: String = ""
var _region_markers: Dictionary = {}  # region_id -> TextureButton

# === Built-in ===
func _ready() -> void:
	_setup_navigation_manager()
	_receive_transition_data()
	_populate_region_markers()
	_update_location_label()
	_connect_signals()

func on_scene_enter(data: Dictionary) -> void:
	if data and not data.is_empty():
		if data.has("region_id") and not data["region_id"].is_empty():
			set_navigation_state(data["region_id"], data.get("building_id", ""))

func _setup_navigation_manager() -> void:
	if navigation_manager == null:
		navigation_manager = NavigationManager.new()
		add_child(navigation_manager)

func _receive_transition_data() -> void:
	var data: Dictionary = SceneManager.get_pending_data()
	if data and not data.is_empty():
		if data.has("region_id") and not data["region_id"].is_empty():
			set_navigation_state(data["region_id"], data.get("building_id", ""))

func _populate_region_markers() -> void:
	var regions: Array[RegionResource] = navigation_manager.get_all_regions()
	
	for region: RegionResource in regions:
		_create_region_marker(region)

func _create_region_marker(region: RegionResource) -> void:
	var button: TextureButton = TextureButton.new()
	button.name = "Region_" + region.region_id
	button.position = region.world_map_position
	button.size = Vector2(64, 64)
	
	if region.icon:
		button.texture_normal = region.icon
	
	var is_unlocked: bool = navigation_manager.is_region_unlocked(region.region_id)
	if not is_unlocked:
		var lock_overlay: TextureRect = TextureRect.new()
		lock_overlay.name = "LockIcon"
		lock_overlay.size = Vector2(32, 32)
		lock_overlay.position = Vector2(16, 16)
		button.add_child(lock_overlay)
	
	var label: Label = Label.new()
	label.text = region.display_name
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.position = Vector2(-20, 68)
	label.size = Vector2(104, 20)
	label.add_theme_color_override("font_color", Color.WHITE)
	if not is_unlocked:
		label.add_theme_color_override("font_color", Color.GRAY)
	button.add_child(label)
	
	button.pressed.connect(_on_region_marker_pressed.bind(region.region_id))
	button.mouse_entered.connect(_on_region_marker_hovered.bind(region.region_id))
	button.mouse_exited.connect(_on_region_marker_unhovered)
	
	_region_markers[region.region_id] = button
	region_container.add_child(button)

func _connect_signals() -> void:
	enter_button.pressed.connect(_on_enter_pressed)
	back_button.pressed.connect(_on_back_pressed)
	
	if navigation_manager:
		navigation_manager.navigation_blocked.connect(_on_navigation_blocked)

# === Signal Handlers ===

func _on_region_marker_pressed(region_id: String) -> void:
	_selected_region_id = region_id
	var region: RegionResource = Database.get_region(region_id) as RegionResource
	if region == null:
		return
	
	region_name_label.text = region.display_name
	description_label.text = region.description
	
	var is_unlocked: bool = navigation_manager.is_region_unlocked(region_id)
	enter_button.disabled = not is_unlocked
	enter_button.visible = is_unlocked
	locked_label.visible = not is_unlocked
	
	if not is_unlocked:
		locked_label.text = "LOCKED: Progress the story to unlock this region."
	
	info_panel.visible = true

func _on_region_marker_hovered(region_id: String) -> void:
	pass

func _on_region_marker_unhovered() -> void:
	pass

func _on_enter_pressed() -> void:
	if _selected_region_id.is_empty():
		return
	
	if navigation_manager.select_region(_selected_region_id):
		navigation_manager.enter_region(_selected_region_id)
		region_entered.emit(_selected_region_id)
		_transition_to_region_hub(_selected_region_id)

func _on_back_pressed() -> void:
	EventBus.emit_event("return_to_previous_scene", {})
	SceneManager.change_scene("res://scenes/ui/main_menu.tscn")

func _on_navigation_blocked(target_id: String, reason: String) -> void:
	EventBus.emit_event("show_notification", {
		"message": reason,
		"duration": 3.0
	})

# === Private Methods ===

func _update_location_label() -> void:
	if navigation_manager and not navigation_manager.current_region_id.is_empty():
		var region: RegionResource = Database.get_region(navigation_manager.current_region_id) as RegionResource
		if region:
			location_label.text = "Current: %s" % region.display_name
			return
	location_label.text = "World Map"

func _transition_to_region_hub(region_id: String) -> void:
	SceneManager.change_scene("res://scenes/world/region_hub.tscn", {
		"region_id": region_id
	})

## Public method to set navigation state when returning to world map.
func set_navigation_state(region_id: String, building_id: String = "") -> void:
	if navigation_manager:
		navigation_manager.current_region_id = region_id
		navigation_manager.current_building_id = building_id
		_update_location_label()