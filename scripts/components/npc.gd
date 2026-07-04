class_name NPC
extends Interactable

## An NPC that can be interacted with in the exploration scene.
##
## When the player interacts, the NPC launches the Visual Novel dialogue
## system with its [member dialogue_id].
##
## Usage:
##     1. Create an NPC scene with an Area2D root + CollisionShape2D.
##     2. Attach this script.
##     3. Set [member dialogue_id] to the dialogue resource ID.

# === Constants ===
const VN_SCENE_PATH: String = "res://scenes/ui/vn/visual_novel.tscn"
const DIALOGUE_DIR: String = "res://database/dialogue/"

# === Exports ===

## The dialogue resource ID to load when interacting.
@export var dialogue_id: String = ""

# === Public Methods ===

func interact(player: Node2D) -> void:
	super(player)
	
	# Validate dialogue_id
	if dialogue_id.is_empty():
		push_warning("NPC: dialogue_id is empty, cannot start dialogue")
		return
	
	# Validate VNManager
	if VNManager == null:
		push_error("NPC: VNManager not available")
		return
	
	# Try to load or compile the dialogue resource
	var dialogue_resource: VNDialogueResource = _load_dialogue()
	if dialogue_resource == null:
		push_warning("NPC: Could not load or compile dialogue: \"%s\"" % dialogue_id)
		return
	
	# Push VN input context to block exploration input
	InputManager.push_context("visual_novel")
	
	# Instance the VN scene on top of the current scene
	var vn_scene: PackedScene = load(VN_SCENE_PATH)
	if vn_scene == null:
		push_error("NPC: Cannot load VN scene: %s" % VN_SCENE_PATH)
		InputManager.pop_context()
		return
	
	var vn_instance: Node = vn_scene.instantiate()
	get_tree().current_scene.add_child(vn_instance)
	
	# Start the dialogue
	VNManager.start_dialogue(dialogue_id)
	
	# Verify dialogue actually started; if not, clean up
	if not VNManager.is_active:
		push_warning("NPC: Dialogue failed to start for \"%s\", cleaning up" % dialogue_id)
		InputManager.pop_context()
		vn_instance.queue_free()

# === Private Methods ===

## Loads a compiled dialogue resource, or compiles the .dialogue file as fallback.
## Mirrors VNPanel._compile_and_start() without saving to disk.
func _load_dialogue() -> VNDialogueResource:
	# Try loading compiled resource first
	var resource: VNDialogueResource = Database.get_dialogue(dialogue_id)
	if resource != null:
		return resource
	
	# Fallback: compile the .dialogue file at runtime
	var source_path: String = DIALOGUE_DIR + dialogue_id + ".dialogue"
	var compiler := VNScriptCompiler.new()
	resource = compiler.compile_file(source_path)
	
	if resource == null:
		push_warning("NPC: Failed to compile dialogue file: %s" % source_path)
		return null
	
	# Override the dialogue_id to match what we expect
	resource.dialogue_id = dialogue_id
	return resource