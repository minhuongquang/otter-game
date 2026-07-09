extends Node

## Handle save file creation, loading, deletion, and versioning.

# === Constants ===
const SAVE_VERSION: String = "1.0.0"
const SAVE_DIR: String = "user://saves/"
const MAX_SLOTS: int = 10
const AUTOSAVE_SLOT: int = 0

# === Signals ===
signal save_completed(slot: int)
signal load_completed(slot: int)
signal save_failed(slot: int, error_message: String)
signal load_failed(slot: int, error_message: String)

# === Public Methods ===

func save_game(slot: int) -> bool:
	var save_data: Dictionary = _collect_save_data()
	var error := _write_save_file(slot, save_data)
	if error == OK:
		save_completed.emit(slot)
		EventBus.emit_event("game_saved", {"slot": slot})
		return true
	else:
		var msg: String = "Failed to save slot %d: error %d" % [slot, error]
		push_error("SaveManager: " + msg)
		save_failed.emit(slot, msg)
		return false

func load_game(slot: int) -> bool:
	var save_data: Dictionary = _read_save_file(slot)
	if save_data.is_empty():
		var msg: String = "Failed to load slot %d: no data" % slot
		push_error("SaveManager: " + msg)
		load_failed.emit(slot, msg)
		return false
	
	_apply_save_data(save_data)
	load_completed.emit(slot)
	EventBus.emit_event("game_loaded", {"slot": slot})
	return true

func delete_save(slot: int) -> bool:
	var path: String = _get_save_path(slot)
	var dir: DirAccess = DirAccess.open(SAVE_DIR)
	if dir and dir.file_exists(path):
		var error := dir.remove(path)
		return error == OK
	return false

func slot_exists(slot: int) -> bool:
	var path: String = _get_save_path(slot)
	return FileAccess.file_exists(path)

func auto_save() -> bool:
	return save_game(AUTOSAVE_SLOT)

# === Lifecycle ===

func _ready() -> void:
	EventBus.listen("battle_finished", _on_battle_finished_autosave)

# === Private Methods ===

func _on_battle_finished_autosave(data: Dictionary) -> void:
	if data.get("outcome", -1) == BattleEnums.BattleOutcome.VICTORY:
		auto_save()


func _get_save_path(slot: int) -> String:
	return SAVE_DIR + "save_" + str(slot) + ".dat"

func _collect_save_data() -> Dictionary:
	return {
		"save_version": SAVE_VERSION,
		"timestamp": Time.get_unix_time_from_system(),
		"playtime": 0.0,
		"story_flags": {},
		"current_scene": SceneManager.get_current_scene_path() if has_node("/root/SceneManager") else "",
		"player_position": Vector2.ZERO,
		"party_members": PartyState.snapshots.duplicate(),
		"inventory": [],
		"currency": 0,
		"quests": [],
		"relationships": {},
		"audio_settings": {},
		"input_bindings": {}
	}

func _write_save_file(slot: int, data: Dictionary) -> int:
	var dir: DirAccess = DirAccess.open("user://")
	if dir and not DirAccess.dir_exists_absolute(SAVE_DIR):
		dir.make_dir_recursive(SAVE_DIR)
	
	var path: String = _get_save_path(slot)
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	
	var json_string: String = JSON.stringify(data)
	file.store_string(json_string)
	file.close()
	return OK

func _read_save_file(slot: int) -> Dictionary:
	var path: String = _get_save_path(slot)
	if not FileAccess.file_exists(path):
		return {}
	
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	
	var json_string: String = file.get_as_text()
	file.close()
	
	var json: JSON = JSON.new()
	var error := json.parse(json_string)
	if error != OK:
		push_error("SaveManager: JSON parse error in slot %d: %s" % [slot, json.get_error_message()])
		return {}
	
	return json.data as Dictionary

func _apply_save_data(data: Dictionary) -> void:
	# Story flags
	if data.has("story_flags"):
		for key: String in data["story_flags"]:
			GlobalFlags.set_flag(key, data["story_flags"][key])
	
	# Party runtime state
	if data.has("party_members"):
		PartyState.snapshots = data["party_members"]
	
	# Scene restoration handled externally by SceneManager
