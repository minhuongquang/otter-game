extends Node

## Global story flag system.
## Tracks story progression, player choices, and game state.
## Flags are persisted by SaveManager during save/load.
##
## Usage:
##   GlobalFlags.set_flag("met_merchant", true)
##   if GlobalFlags.get_flag("met_merchant", false):
##       ...

# === Private ===
var _flags: Dictionary = {}

# === Public Methods ===

## Set a flag to a value (typically bool, int, or String).
func set_flag(key: String, value: Variant) -> void:
	_flags[key] = value

## Get a flag value, returning default_value if not set.
func get_flag(key: String, default_value: Variant = null) -> Variant:
	return _flags.get(key, default_value)

## Check if a flag exists.
func has_flag(key: String) -> bool:
	return _flags.has(key)

## Remove a flag entirely.
func erase_flag(key: String) -> void:
	_flags.erase(key)

## Get all flags as a Dictionary (for save serialization).
func get_all_flags() -> Dictionary:
	return _flags.duplicate()

## Overwrite all flags from a Dictionary (for save deserialization).
func set_all_flags(flags: Dictionary) -> void:
	_flags = flags.duplicate()

## Clear all flags.
func clear_all_flags() -> void:
	_flags.clear()
