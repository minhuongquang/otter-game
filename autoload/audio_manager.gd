extends Node

## Play BGM, SFX, manage audio buses, crossfade transitions.

# === Constants ===
const BUS_MASTER: String = "Master"
const BUS_BGM: String = "BGM"
const BUS_SFX: String = "SFX"
const BUS_VOICE: String = "Voice"

# === Signals ===
signal bgm_changed(bgm_id: String)
signal sfx_played(sfx_id: String)

# === Private ===
var _current_bgm: AudioStreamPlayer = null
var _crossfade_tween: Tween = null

# === Public Methods ===

func play_bgm(stream: AudioStream, fade_in: float = 0.0) -> void:
	if _current_bgm and _current_bgm.playing:
		_fade_out_bgm(fade_in)
	
	_current_bgm = AudioStreamPlayer.new()
	_current_bgm.bus = BUS_BGM
	_current_bgm.stream = stream
	add_child(_current_bgm)
	
	if fade_in > 0.0:
		_current_bgm.volume_db = -80.0
		var tween: Tween = create_tween()
		tween.tween_property(_current_bgm, "volume_db", 0.0, fade_in)
	
	_current_bgm.play()
	bgm_changed.emit(stream.resource_path)
	EventBus.emit_event("audio_bgm_changed", {"bgm_path": stream.resource_path})

func play_sfx(stream: AudioStream, bus: String = BUS_SFX) -> void:
	var player: AudioStreamPlayer = AudioStreamPlayer.new()
	player.bus = bus
	player.stream = stream
	add_child(player)
	player.finished.connect(_on_sfx_finished.bind(player))
	player.play()
	sfx_played.emit(stream.resource_path)
	EventBus.emit_event("audio_sfx_played", {"sfx_path": stream.resource_path})

func stop_bgm(fade_out: float = 0.0) -> void:
	if not _current_bgm:
		return
	
	if fade_out > 0.0:
		_fade_out_bgm(fade_out)
	else:
		_current_bgm.stop()
		_current_bgm.queue_free()
		_current_bgm = null

func set_bus_volume(bus_name: String, volume_db: float) -> void:
	var bus_index: int = AudioServer.get_bus_index(bus_name)
	if bus_index >= 0:
		AudioServer.set_bus_volume_db(bus_index, volume_db)

func get_bus_volume(bus_name: String) -> float:
	var bus_index: int = AudioServer.get_bus_index(bus_name)
	if bus_index >= 0:
		return AudioServer.get_bus_volume_db(bus_index)
	return 0.0

# === Private Methods ===

func _fade_out_bgm(duration: float) -> void:
	if not _current_bgm:
		return
	
	if _crossfade_tween and _crossfade_tween.is_valid():
		_crossfade_tween.kill()
	
	_crossfade_tween = create_tween()
	_crossfade_tween.tween_property(_current_bgm, "volume_db", -80.0, duration)
	_crossfade_tween.tween_callback(_cleanup_bgm)

func _cleanup_bgm() -> void:
	if _current_bgm:
		_current_bgm.stop()
		_current_bgm.queue_free()
		_current_bgm = null

func _on_sfx_finished(player: AudioStreamPlayer) -> void:
	if is_instance_valid(player):
		player.queue_free()
