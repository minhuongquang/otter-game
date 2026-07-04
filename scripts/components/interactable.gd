class_name Interactable
extends Area2D
## Base class for interactable world objects.
##
## An Interactable is an [Area2D] that the player can detect and interact with
## by pressing the Interact action (default: E).
##
## Subclasses must override [method interact] to define what happens when the
## player interacts. Override [method can_interact] if additional conditions
## are needed beyond the default one-time check.
##
## Usage:
##     1. Create a scene with an Area2D root node and a CollisionShape2D child.
##     2. Attach a script that extends Interactable.
##     3. Override interact(player: Node2D) to add custom behavior.
##
## Example:
## @tool
## extends Interactable
## func interact(player: Node2D) -> void:
##     print("Trigger activated!")

# === Signals ===

## Emitted when the player interacts with this object.
## Subclasses may emit this or call it from [method interact].
signal interacted(player: Node2D)

# === Exports ===

## Optional label shown in the interaction prompt (not yet wired to UI).
@export var prompt: String = "Interact"

## If [code]true[/code], this object can only be interacted with once.
@export var one_time: bool = false

# === Built-in ===

func _ready() -> void:
	## Interactables live on collision layer 2 by default.
	## PlayerController's InteractionDetector uses mask 2 to find them.
	collision_layer = 2
	collision_mask = 0
	monitorable = true
	monitoring = false

# === Private ===

## Tracks whether this object has already been interacted with.
var _interacted: bool = false

# === Public Methods ===

## Returns [code]true[/code] if the player can interact with this object.
##
## The default implementation returns [code]false[/code] if [member one_time]
## is [code]true[/code] and this object has already been interacted with.
## Override to add custom conditions (e.g., quest state, item requirement).
func can_interact(_player: Node2D) -> bool:
	if one_time and _interacted:
		return false
	return true

## Called when the player interacts with this object.
##
## The default implementation emits [signal interacted] and marks the
## object as interacted if [member one_time] is [code]true[/code].
## Subclasses should override this method to define custom behavior.
func interact(player: Node2D) -> void:
	interacted.emit(player)
	if one_time:
		_interacted = true