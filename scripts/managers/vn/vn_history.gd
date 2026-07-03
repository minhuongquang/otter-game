class_name VNHistory
extends RefCounted

## Stores dialogue history entries for the player to review.
## History is scoped to the current session (not persisted in saves).

var entries: Array[VNHistoryEntry] = []
const MAX_ENTRIES: int = 1000

## Add a dialogue line to the history.
func add_entry(speaker: String, text: String, portrait_path: String = "", dialogue_id: String = "", line_index: int = -1) -> void:
	var entry := VNHistoryEntry.new()
	entry.speaker = speaker
	entry.text = text
	entry.portrait_path = portrait_path
	entry.dialogue_id = dialogue_id
	entry.line_index = line_index
	entry.timestamp = Time.get_unix_time_from_system()
	
	entries.append(entry)
	
	# Trim history if exceeds max
	if entries.size() > MAX_ENTRIES:
		entries.remove_at(0)

## Get all history entries.
func get_entries() -> Array[VNHistoryEntry]:
	return entries.duplicate()

## Get entries filtered by dialogue_id.
func get_entries_by_dialogue(dialogue_id: String) -> Array[VNHistoryEntry]:
	var result: Array[VNHistoryEntry] = []
	for entry in entries:
		if entry.dialogue_id == dialogue_id:
			result.append(entry)
	return result

## Get the most recent entry.
func get_last_entry() -> VNHistoryEntry:
	if entries.is_empty():
		return null
	return entries[entries.size() - 1]

## Get the number of entries.
func get_entry_count() -> int:
	return entries.size()

## Clear all history.
func clear() -> void:
	entries.clear()


class VNHistoryEntry:
	extends RefCounted
	
	## Speaker display name.
	var speaker: String = ""
	## Dialogue text.
	var text: String = ""
	## Path to the portrait texture (for display in history UI).
	var portrait_path: String = ""
	## Dialogue ID this entry belongs to.
	var dialogue_id: String = ""
	## Line index within the dialogue.
	var line_index: int = -1
	## Unix timestamp when the line was displayed.
	var timestamp: float = 0.0
	
	func _to_string() -> String:
		return "%s: %s" % [speaker, text]