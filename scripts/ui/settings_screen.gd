class_name SettingsScreen
extends Control

## Settings menu with BGM/SFX volume sliders, display mode, and back navigation.
## Settings persistence is not yet implemented.

# === @onready ===
@onready var bgm_slider: HSlider = $SettingsContainer/BGM_Row/BGM_Slider
@onready var sfx_slider: HSlider = $SettingsContainer/SFX_Row/SFX_Slider
@onready var display_mode_option: OptionButton = $SettingsContainer/Display_Row/DisplayModeOption
@onready var back_button: Button = $BackButton

# === Private ===
var _focus_targets: Array[Control] = []

# === Built-in ===
func _ready() -> void:
	_load_current_values()
	_build_focus_list()
	bgm_slider.grab_focus()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_menu") or event.is_action_pressed("ui_cancel"):
		_on_back_pressed()
		return
	
	if event.is_action_pressed("ui_up") or event.is_action_pressed("ui_down"):
		_move_focus(event.is_action_pressed("ui_down"))
		get_viewport().set_input_as_handled()
		return
	
	if event.is_action_pressed("ui_left") or event.is_action_pressed("ui_right"):
		_adjust_current_control(event.is_action_pressed("ui_right"))
		get_viewport().set_input_as_handled()

# === Focus Management ===

func _build_focus_list() -> void:
	_focus_targets = [bgm_slider, sfx_slider, display_mode_option, back_button]

func _move_focus(is_down: bool) -> void:
	var current: Control = get_viewport().gui_get_focus_owner()
	if current == null:
		bgm_slider.grab_focus()
		return
	
	var idx: int = _focus_targets.find(current)
	if idx == -1:
		bgm_slider.grab_focus()
		return
	
	if is_down:
		idx = (idx + 1) % _focus_targets.size()
	else:
		idx = idx - 1
		if idx < 0:
			idx = _focus_targets.size() - 1
	
	_focus_targets[idx].grab_focus()

func _adjust_current_control(is_increase: bool) -> void:
	var current: Control = get_viewport().gui_get_focus_owner()
	if current == null:
		return
	
	if current is HSlider:
		var slider: HSlider = current as HSlider
		var step_size: float = slider.step
		slider.value = clamp(slider.value + (step_size if is_increase else -step_size), slider.min_value, slider.max_value)
	elif current is OptionButton:
		var opt: OptionButton = current as OptionButton
		var new_idx: int = opt.selected
		if is_increase:
			new_idx = (opt.selected + 1) % opt.item_count
		else:
			new_idx = opt.selected - 1
			if new_idx < 0:
				new_idx = opt.item_count - 1
		opt.select(new_idx)
		_on_display_mode_changed(new_idx)

# === Initialization ===

func _load_current_values() -> void:
	bgm_slider.value = _db_to_percent(AudioManager.get_bus_volume("BGM"))
	sfx_slider.value = _db_to_percent(AudioManager.get_bus_volume("SFX"))
	_sync_display_mode()

func _sync_display_mode() -> void:
	var mode: DisplayServer.WindowMode = DisplayServer.window_get_mode()
	match mode:
		DisplayServer.WINDOW_MODE_FULLSCREEN:
			display_mode_option.select(1)
		_:
			display_mode_option.select(0)

# === Audio Callbacks ===

func _on_bgm_volume_changed(value: float) -> void:
	AudioManager.set_bus_volume("BGM", _percent_to_db(value))

func _on_sfx_volume_changed(value: float) -> void:
	AudioManager.set_bus_volume("SFX", _percent_to_db(value))

# === Display Callback ===

func _on_display_mode_changed(index: int) -> void:
	match index:
		0:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		1:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

# === Navigation ===

func _on_back_pressed() -> void:
	UIManager.close_screen("settings")

# === Audio Unit Conversion ===

func _percent_to_db(percent: float) -> float:
	if percent <= 0.0:
		return -80.0
	return linear_to_db(percent / 100.0)

func _db_to_percent(db: float) -> float:
	return db_to_linear(db) * 100.0