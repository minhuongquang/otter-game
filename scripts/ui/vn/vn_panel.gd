extends CanvasLayer
class_name VNPanel

## Main UI controller for the Visual Novel scene.
## Manages background, character portraits, dialogue box, choices, and quick menu.
## Also handles VNManager lifecycle and dialogue compilation.
##
## When the VN scene is instanced by an NPC interaction, VNManager (autoload)
## is used instead of creating a local instance. On dialogue end, this panel
## cleans itself up and restores the gameplay input context.

# === Constants ===
const MAIN_MENU_PATH: String = "res://scenes/ui/main_menu.tscn"
const WORLD_MAP_PATH: String = "res://scenes/world/world_map.tscn"
const PROLOGUE_DIALOGUE_ID: String = "prologue_001"
const PROLOGUE_DIALOGUE_FILE: String = "res://database/dialogue/sample_prologue.dialogue"

# === Exports ===
@export var dialogue_id: String = PROLOGUE_DIALOGUE_ID

# === @onready ===
@onready var background: TextureRect = $VNBackground
@onready var character_layer: Node2D = $VNCharacterLayer
@onready var dialogue_box: Control = $VNDialogueBox
@onready var name_label: Label = $VNDialogueBox/VNNameLabel
@onready var text_label: RichTextLabel = $VNDialogueBox/VNTextLabel
@onready var next_indicator: TextureRect = $VNDialogueBox/VNNextIndicator
@onready var choice_panel: Control = $VNChoicePanel
@onready var quick_menu: HBoxContainer = $VNQuickMenu
@onready var history_log: Panel = $VNHistoryLog

# === Public ===
var vn_manager: Node = null

# === Private ===
var _portraits: Dictionary = {}  # character_id -> VNPortrait
var _instanced_by_npc: bool = false  # true if launched by NPC (not boot/M1 flow)

# === Built-in ===
func _ready() -> void:
	# Detect if this was launched by an NPC (has a parent scene already)
	_instanced_by_npc = get_parent() != get_tree().root
	
	# Listen to VN events
	EventBus.listen("vn_change_background", _on_change_background)
	EventBus.listen("vn_show_character", _on_show_character)
	EventBus.listen("vn_hide_character", _on_hide_character)
	EventBus.listen("vn_change_expression", _on_change_expression)
	EventBus.listen("vn_show_choices", _on_show_choices)
	EventBus.listen("vn_show_history", _on_show_history)
	EventBus.listen("vn_shake_camera", _on_shake_camera)
	EventBus.listen("vn_fade", _on_fade)
	EventBus.listen("vn_animation", _on_animation)
	
	# Hide UI elements initially
	choice_panel.hide()
	history_log.hide()
	next_indicator.hide()
	
	# Set up VN manager
	_setup_vn_manager()

func _exit_tree() -> void:
	EventBus.unlisten("vn_change_background", _on_change_background)
	EventBus.unlisten("vn_show_character", _on_show_character)
	EventBus.unlisten("vn_hide_character", _on_hide_character)
	EventBus.unlisten("vn_change_expression", _on_change_expression)
	EventBus.unlisten("vn_show_choices", _on_show_choices)
	EventBus.unlisten("vn_show_history", _on_show_history)
	EventBus.unlisten("vn_shake_camera", _on_shake_camera)
	EventBus.unlisten("vn_fade", _on_fade)
	EventBus.unlisten("vn_animation", _on_animation)

func _input(event: InputEvent) -> void:
	if vn_manager == null or not vn_manager.is_active:
		return
	
	# Advance on click or Enter/Space
	if event.is_action_pressed("ui_accept") or (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed):
		# Only advance if not in CHOICE state
		if vn_manager.get_state() != 3:  # VNState.CHOICE
			EventBus.emit_event("vn_advance", {})
		get_viewport().set_input_as_handled()

# === VNManager Lifecycle ===

func _setup_vn_manager() -> void:
	# Use the autoload VNManager
	vn_manager = VNManager
	
	# Guard against transient engine timing issues during scene transitions
	if not is_instance_valid(vn_manager):
		push_error("VNPanel: VNManager autoload is not valid. Cannot initialize VN.")
		return
	
	# Set the VN panel reference so VNManager can update this UI
	vn_manager.vn_panel = self
	
	# Connect to VNManager signals
	if not vn_manager.vn_ended.is_connected(_on_vn_ended):
		vn_manager.vn_ended.connect(_on_vn_ended)
	
	# Start dialogue (for NPC-instanced, the NPC already called start_dialogue;
	# for boot/main-menu flow, we compile and start here)
	if not _instanced_by_npc:
		_compile_and_start()

func _compile_and_start() -> void:
	# Try to load pre-compiled resource first
	var resource: VNDialogueResource = Database.get_dialogue(dialogue_id)
	
	if resource == null:
		# Fallback: compile from embedded dialogue text
		resource = _compile_prologue()
	
	if resource == null:
		push_error("VNPanel: Could not load or compile dialogue: %s" % dialogue_id)
		return
	
	# Register the resource with Database so VNManager can find it
	Database._cache["dialogue/" + dialogue_id] = resource
	
	# Start the dialogue
	vn_manager.start_dialogue(dialogue_id)

func _compile_prologue() -> VNDialogueResource:
	var compiler := VNScriptCompiler.new()
	var source_text: String = _get_prologue_source()
	var resource: VNDialogueResource = compiler.compile_text(source_text, "sample_prologue.dialogue")
	
	if resource == null:
		push_error("VNPanel: Failed to compile prologue dialogue from source")
		return null
	
	# Ensure dialogue_id matches
	resource.dialogue_id = dialogue_id
	return resource

func _get_prologue_source() -> String:
	return """[META]
id: "prologue_001"
bg: "res://assets/art/backgrounds/castle_hall.png"
bgm: "res://assets/audio/bgm/melancholy.ogg"
on_start: []
on_end: [{"type": "set_flag", "key": "prologue_seen", "value": true}]

[CHARACTERS]
saria = "res://database/characters/saria.tres"
lyra = "res://database/characters/lyra.tres"

[VARIABLES]
trust_level: 0
met_saria: false

[SCRIPT]
LABEL start

# Introduction scene
LINE saria "Saria" smile "Welcome, traveler. I've been expecting you."

# Branch based on story flag
BRANCH prologue_seen == true JUMP greeting_again

LABEL first_time

LINE saria "Saria" neutral "This is your first time here, isn't it?"

CHOICE "Yes, I'm new to this place."
    SET_FLAG met_saria true
    JUMP after_intro

CHOICE "I've been here before..."
    SET_VAR trust_level +5
    JUMP after_intro

LABEL greeting_again

LINE saria "Saria" happy "Welcome back! I'm glad to see you again."

LABEL after_intro

LINE saria "Saria" neutral "Let me introduce you to everyone."

SHOW lyra right fade_in

LINE lyra "Lyra" happy "Hey there! I'm Lyra!"

SHAKE 0.3 0.5

LINE lyra "Lyra" neutral "Oops, sorry. Got a bit excited there."

CHOICE "Nice to meet you, Lyra!"
    SET_VAR trust_level +2
    JUMP tour_start

CHOICE "You seem energetic..."
    SET_VAR trust_level +1
    JUMP tour_start

LABEL tour_start

LINE saria "Saria" smile "Let me show you around the castle."

BACKGROUND "res://assets/art/backgrounds/castle_hallway.png" FADE 1.0

BGM "res://assets/audio/bgm/exploration.ogg" 0.5

LINE saria "Saria" neutral "This is the main hallway. The library is to the left."

WAIT 1.0

EXPR lyra excited

LINE lyra "Lyra" excited "And the kitchen is to the right! I'll show you later!"

HIDE lyra fade_out

LINE saria "Saria" smile "She's always like that. You'll get used to it."

GIVE_ITEM old_map 1

LINE saria "Saria" neutral "Here, take this map. It might help you find your way."

UNLOCK_REGION castle_interior

# Battle tutorial trigger
START_BATTLE training_dummy

LINE saria "Saria" smile "Not bad for a first try!"
"""

func _on_vn_ended(_dialogue_id: String) -> void:
	# Disconnect from VNManager to avoid double-calls
	if vn_manager != null and vn_manager.vn_ended.is_connected(_on_vn_ended):
		vn_manager.vn_ended.disconnect(_on_vn_ended)
	
	if _instanced_by_npc:
		# Return to gameplay: pop input context and remove this panel
		InputManager.pop_context()
		queue_free()
	else:
		# Boot/Main Menu flow: transition to WorldMap
		SceneManager.change_scene(WORLD_MAP_PATH)

# === UI Methods ===

## Set the VNManager reference.
func set_manager(manager: Node) -> void:
	vn_manager = manager

## Update the dialogue display with current line data.
func update_dialogue(line_data: Dictionary) -> void:
	if line_data.is_empty():
		dialogue_box.hide()
		return
	
	dialogue_box.show()
	name_label.text = line_data.get("display_name", "")
	text_label.text = line_data.get("text", "")
	
	# Start typewriter effect
	if vn_manager != null:
		vn_manager.typewriter.start_display(line_data.get("text", ""), text_label)
	
	# Update character expression
	var speaker_id: String = line_data.get("speaker_id", "")
	var emotion: String = line_data.get("emotion", "neutral")
	if _portraits.has(speaker_id):
		_portraits[speaker_id].set_expression(emotion)
	
	# Show next indicator after typewriter finishes
	next_indicator.hide()

## Show the next indicator (called when typewriter finishes).
func show_next_indicator() -> void:
	next_indicator.show()
	# Animate the indicator
	var tween := create_tween()
	tween.tween_property(next_indicator, "modulate:a", 1.0, 0.5)
	tween.tween_property(next_indicator, "modulate:a", 0.3, 0.5)
	tween.set_loops()

## Hide the next indicator.
func hide_next_indicator() -> void:
	next_indicator.hide()

# === Event Handlers ===

func _on_change_background(data: Dictionary) -> void:
	var texture_path: String = data.get("texture_path", "")
	var transition: String = data.get("transition", "fade")
	var duration: float = data.get("duration", 1.0)
	
	if not texture_path.is_empty():
		var texture: Texture2D = load(texture_path) as Texture2D
		if texture != null:
			# Apply transition
			match transition:
				"fade":
					var tween := create_tween()
					tween.tween_property(background, "modulate:a", 0.0, duration * 0.5)
					tween.tween_callback(func(): background.texture = texture)
					tween.tween_property(background, "modulate:a", 1.0, duration * 0.5)
				_:
					background.texture = texture

func _on_show_character(data: Dictionary) -> void:
	var character_id: String = data.get("character_id", "")
	var position: String = data.get("position", "center")
	var animation: String = data.get("animation", "fade_in")
	
	if _portraits.has(character_id):
		# Already shown, just update position
		_portraits[character_id].show()
		return
	
	# Load character resource
	var char_resource: CharacterResource = Database.get_character(character_id)
	if char_resource == null:
		return
	
	# Create portrait instance directly from script
	var portrait := VNPortrait.new()
	portrait.setup(character_id, char_resource)
	
	# Set position
	var pos: Vector2 = _get_position_for(position)
	portrait.position = pos
	
	character_layer.add_child(portrait)
	_portraits[character_id] = portrait
	
	# Apply entrance animation
	match animation:
		"fade_in":
			portrait.modulate.a = 0.0
			var tween := create_tween()
			tween.tween_property(portrait, "modulate:a", 1.0, 0.5)
		"slide_left":
			portrait.position.x += 200
			var tween := create_tween()
			tween.tween_property(portrait, "position:x", pos.x, 0.5)
		"slide_right":
			portrait.position.x -= 200
			var tween := create_tween()
			tween.tween_property(portrait, "position:x", pos.x, 0.5)

func _on_hide_character(data: Dictionary) -> void:
	var character_id: String = data.get("character_id", "")
	var animation: String = data.get("animation", "fade_out")
	
	if not _portraits.has(character_id):
		return
	
	var portrait: Node = _portraits[character_id]
	
	match animation:
		"fade_out":
			var tween := create_tween()
			tween.tween_property(portrait, "modulate:a", 0.0, 0.3)
			tween.tween_callback(func(): portrait.hide())
		_:
			portrait.hide()

func _on_change_expression(data: Dictionary) -> void:
	var character_id: String = data.get("character_id", "")
	var emotion: String = data.get("emotion", "neutral")
	
	if _portraits.has(character_id):
		_portraits[character_id].set_expression(emotion)

func _on_show_choices(data: Dictionary) -> void:
	var choices: Array = data.get("choices", [])
	if choices.is_empty():
		choice_panel.hide()
		return
	
	# Clear existing choice buttons
	for child in choice_panel.get_children():
		child.queue_free()
	
	# Create choice buttons
	for i in range(choices.size()):
		var choice_data: VNChoiceData = choices[i] as VNChoiceData
		var button := Button.new()
		button.text = choice_data.choice_text
		button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		button.pressed.connect(_on_choice_button_pressed.bind(i))
		choice_panel.add_child(button)
	
	choice_panel.show()

func _on_show_history(data: Dictionary) -> void:
	var entries: Array = data.get("entries", [])
	if entries.is_empty():
		return
	
	# Get or create a content container inside the history panel
	var container: VBoxContainer
	if history_log.has_node("VBoxContainer"):
		container = history_log.get_node("VBoxContainer") as VBoxContainer
	else:
		container = VBoxContainer.new()
		container.name = "VBoxContainer"
		container.anchor_right = 1.0
		container.anchor_bottom = 1.0
		history_log.add_child(container)
	
	# Clear existing entries
	for child in container.get_children():
		child.queue_free()
	
	# Populate history
	for entry in entries:
		var label := Label.new()
		# Handle both Dictionary entries and VNHistoryEntry objects
		var speaker: String = entry.get("speaker", "") if entry is Dictionary else entry.speaker
		var text: String = entry.get("text", "") if entry is Dictionary else entry.text
		label.text = "[%s] %s" % [speaker, text]
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		container.add_child(label)
	
	history_log.show()

func _on_shake_camera(data: Dictionary) -> void:
	var intensity: float = data.get("intensity", 0.3)
	var duration: float = data.get("duration", 0.5)
	
	var original_pos := character_layer.position
	var tween := create_tween()
	
	# Random shake
	for i in range(10):
		var shake_offset := Vector2(
			randf_range(-intensity, intensity) * 10.0,
			randf_range(-intensity, intensity) * 10.0
		)
		tween.tween_callback(func(): character_layer.position = original_pos + shake_offset)
		tween.tween_interval(duration / 10.0)
	
	tween.tween_callback(func(): character_layer.position = original_pos)

func _on_fade(data: Dictionary) -> void:
	var target_color: String = data.get("target_color", "black")
	var custom_color: Color = data.get("custom_color", Color.BLACK)
	var duration: float = data.get("duration", 1.0)
	
	var color: Color
	match target_color:
		"black":
			color = Color.BLACK
		"white":
			color = Color.WHITE
		_:
			color = custom_color
	
	# Create a fade overlay
	var overlay := ColorRect.new()
	overlay.color = Color.TRANSPARENT
	overlay.size = get_viewport().get_visible_rect().size
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(overlay)
	
	var tween := create_tween()
	tween.tween_property(overlay, "color", color, duration)
	tween.tween_callback(func(): overlay.queue_free())

func _on_animation(data: Dictionary) -> void:
	var target: String = data.get("target", "")
	var animation_id: String = data.get("animation_id", "")
	var params: Dictionary = data.get("params", {})
	
	match target:
		"background":
			_animate_node(background, animation_id, params)
		_:
			if _portraits.has(target):
				_animate_node(_portraits[target], animation_id, params)

# === Input ===

func _on_choice_button_pressed(index: int) -> void:
	EventBus.emit_event("vn_make_choice", {"index": index})
	choice_panel.hide()

# === Helpers ===

func _get_position_for(position_name: String) -> Vector2:
	var viewport_size := get_viewport().get_visible_rect().size
	match position_name:
		"far_left":
			return Vector2(viewport_size.x * 0.1, viewport_size.y * 0.5)
		"left":
			return Vector2(viewport_size.x * 0.25, viewport_size.y * 0.5)
		"center":
			return Vector2(viewport_size.x * 0.5, viewport_size.y * 0.5)
		"right":
			return Vector2(viewport_size.x * 0.75, viewport_size.y * 0.5)
		"far_right":
			return Vector2(viewport_size.x * 0.9, viewport_size.y * 0.5)
		_:
			return Vector2(viewport_size.x * 0.5, viewport_size.y * 0.5)

func _animate_node(node: Node, animation_id: String, _params: Dictionary) -> void:
	match animation_id:
		"bounce":
			var tween := create_tween()
			var original_y: float = node.position.y
			tween.tween_property(node, "position:y", original_y - 20, 0.1)
			tween.tween_property(node, "position:y", original_y, 0.1)
		"shake":
			var original_pos: Vector2 = node.position
			var tween := create_tween()
			for i in range(5):
				tween.tween_property(node, "position", original_pos + Vector2(5, 0), 0.05)
				tween.tween_property(node, "position", original_pos - Vector2(5, 0), 0.05)
			tween.tween_property(node, "position", original_pos, 0.05)
		"flash":
			var original_modulate: Color = node.modulate
			var tween := create_tween()
			tween.tween_property(node, "modulate", Color.WHITE, 0.05)
			tween.tween_property(node, "modulate", original_modulate, 0.1)
