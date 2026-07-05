extends CanvasLayer

## Controller for the RegionHub scene.
## Shows available buildings, NPCs, and quick actions for the current region.

# === Exports ===
@export var navigation_manager: NavigationManager = null

# === Node References ===
@onready var region_name_label: Label = $RegionName
@onready var building_container: Node = $BuildingContainer
@onready var npc_list: VBoxContainer = $NPCPanel/NPCList
@onready var quick_actions: HBoxContainer = $QuickActions
@onready var exit_button: Button = $ExitButton
@onready var quest_tracker: VBoxContainer = $QuestTracker

# === Private ===
var _current_region: RegionResource = null
var _building_scenes: Dictionary = {}  # building_id -> Button

# === Built-in ===
func _ready() -> void:
	_setup_navigation_manager()
	_receive_transition_data()
	_load_current_region()
	_populate_building_markers()
	_populate_npc_list()
	_setup_quick_actions()
	_connect_signals()

func _setup_navigation_manager() -> void:
	if navigation_manager == null:
		navigation_manager = NavigationManager.new()
		add_child(navigation_manager)

func _load_current_region() -> void:
	_current_region = navigation_manager.get_current_region()
	if _current_region == null:
		push_error("RegionHub: No current region set in NavigationManager")
		return
	
	region_name_label.text = _current_region.display_name

func _populate_building_markers() -> void:
	if _current_region == null:
		return
	
	for building: BuildingEntry in _current_region.buildings:
		_create_building_button(building)

func _create_building_button(building: BuildingEntry) -> void:
	var button: Button = Button.new()
	button.name = "Building_" + building.building_id
	button.text = building.display_name
	button.size = Vector2(200, 40)
	button.tooltip_text = building.description
	
	# Check if building is unlocked
	var is_unlocked: bool = true
	if not building.required_flag.is_empty():
		is_unlocked = GlobalFlags.get_flag(building.required_flag, false)
	
	button.disabled = not is_unlocked
	if not is_unlocked:
		button.text += " [LOCKED]"
	
	button.pressed.connect(_on_building_pressed.bind(building))
	
	_building_scenes[building.building_id] = button
	building_container.add_child(button)

func _populate_npc_list() -> void:
	if _current_region == null or _current_region.npc_ids.is_empty():
		npc_list.visible = false
		return
	
	npc_list.visible = true
	for child in npc_list.get_children():
		child.queue_free()
	
	for npc_id: String in _current_region.npc_ids:
		var character: CharacterResource = Database.get_character(npc_id) as CharacterResource
		if character == null:
			continue
		
		var label: Label = Label.new()
		label.text = character.display_name
		label.size = Vector2(200, 24)
		npc_list.add_child(label)

func _setup_quick_actions() -> void:
	if _current_region == null:
		return
	
	# Clear existing quick action buttons (keep template if any)
	for child in quick_actions.get_children():
		child.queue_free()
	
	# Check for inn
	for building: BuildingEntry in _current_region.buildings:
		match building.building_type:
			BuildingType.Type.INN:
				var inn_btn: Button = Button.new()
				inn_btn.text = "Rest at Inn"
				inn_btn.pressed.connect(_on_inn_pressed.bind(building))
				quick_actions.add_child(inn_btn)
			
			BuildingType.Type.SHOP:
				var shop_btn: Button = Button.new()
				shop_btn.text = "Visit Shop"
				shop_btn.pressed.connect(_on_shop_pressed.bind(building))
				quick_actions.add_child(shop_btn)
			
			BuildingType.Type.DUNGEON_ENTRY:
				var dungeon_btn: Button = Button.new()
				dungeon_btn.text = "Enter Dungeon"
				dungeon_btn.pressed.connect(_on_dungeon_pressed.bind(building))
				quick_actions.add_child(dungeon_btn)
			
			BuildingType.Type.TEMPLE:
				var temple_btn: Button = Button.new()
				temple_btn.text = "Visit Temple"
				temple_btn.pressed.connect(_on_temple_pressed.bind(building))
				quick_actions.add_child(temple_btn)

func _receive_transition_data() -> void:
	var data: Dictionary = SceneManager.get_pending_data()
	if data and not data.is_empty():
		if data.has("region_id") and not data["region_id"].is_empty():
			if navigation_manager:
				navigation_manager.current_region_id = data["region_id"]
				navigation_manager.current_building_id = data.get("building_id", "")
			_current_region = navigation_manager.get_current_region()
			if _current_region:
				region_name_label.text = _current_region.display_name

func _connect_signals() -> void:
	exit_button.pressed.connect(_on_exit_pressed)

# === Signal Handlers ===

func _on_building_pressed(building: BuildingEntry) -> void:
	if navigation_manager.enter_building(building.building_id):
		_transition_to_building(building)

func _on_exit_pressed() -> void:
	navigation_manager.exit_region()
	_transition_to_world_map()

func _on_inn_pressed(building: BuildingEntry) -> void:
	if navigation_manager.enter_building(building.building_id):
		# Show inn rest dialog then transition
		EventBus.emit_event("show_inn_dialog", {
			"building_id": building.building_id,
			"scene_path": building.scene_path
		})

func _on_shop_pressed(building: BuildingEntry) -> void:
	if navigation_manager.enter_building(building.building_id):
		# Show shop UI directly without full building transition
		var shop: ShopResource = navigation_manager.get_shop_for_building(building) as ShopResource
		if shop:
			EventBus.emit_event("open_shop", {
				"shop_id": shop.shop_id,
				"shop_name": shop.shop_name
			})

func _on_dungeon_pressed(building: BuildingEntry) -> void:
	if navigation_manager.enter_building(building.building_id):
		# Transition to exploration scene
		EventBus.emit_event("enter_dungeon", {
			"building_id": building.building_id,
			"region_id": navigation_manager.current_region_id
		})
		if not building.scene_path.is_empty():
			SceneManager.change_scene(building.scene_path, {
				"building_id": building.building_id,
				"region_id": navigation_manager.current_region_id
			})

func _on_temple_pressed(building: BuildingEntry) -> void:
	if navigation_manager.enter_building(building.building_id):
		# Temple: heal party and save
		EventBus.emit_event("heal_party", {})
		EventBus.emit_event("show_notification", {
			"message": "Your party has been healed.",
			"duration": 2.0
		})
		navigation_manager.exit_building()

# === Private Methods ===

func _transition_to_building(building: BuildingEntry) -> void:
	if not building.scene_path.is_empty():
		SceneManager.change_scene(building.scene_path, {
			"building_id": building.building_id,
			"region_id": navigation_manager.current_region_id
		})
	else:
		push_warning("RegionHub: Building %s has no scene_path set." % building.building_id)

func _transition_to_world_map() -> void:
	SceneManager.change_scene("res://scenes/world/world_map.tscn", {
		"returning_from_region": true
	})