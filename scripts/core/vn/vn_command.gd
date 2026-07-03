class_name VNCommand
extends Resource

## Base class for all Visual Novel commands.
## Each command type extends this and implements its own data fields.
## The command_type string is used by VNCommandExecutor to dispatch to the correct handler.

@export var command_type: String = ""
@export var blocking: bool = false  # If true, VNStateMachine waits for completion

## Returns a Dictionary of parameters for custom command handlers.
func get_params() -> Dictionary:
	return {}