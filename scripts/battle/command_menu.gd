## CommandMenu — player action selection. Emits action_requested(CommandType).
class_name CommandMenu
extends HBoxContainer

# ─── Signals ──────────────────────────────────────────────────────────────────
signal action_requested(action: BattleEnums.CommandType)

# ─── @onready ─────────────────────────────────────────────────────────────────
@onready var attack_button: Button = %AttackButton
@onready var skill_button: Button = %SkillButton
@onready var guard_button: Button = %GuardButton
@onready var item_button: Button = %ItemButton
@onready var flee_button: Button = %FleeButton

# ─── Lifecycle ────────────────────────────────────────────────────────────────
func _ready() -> void:
	attack_button.pressed.connect(_on_attack_pressed)
	skill_button.pressed.connect(_on_skill_pressed)
	guard_button.pressed.connect(_on_guard_pressed)
	item_button.pressed.connect(_on_item_pressed)
	flee_button.pressed.connect(_on_flee_pressed)
	disable()

# ─── Public API ───────────────────────────────────────────────────────────────
func enable() -> void:
	attack_button.disabled = false
	# Enable other buttons based on current state
	skill_button.disabled = false
	guard_button.disabled = false
	_refresh_item_button()
	flee_button.disabled = false

func disable() -> void:
	attack_button.disabled = true
	skill_button.disabled = true
	guard_button.disabled = true
	item_button.disabled = true
	flee_button.disabled = true

# ─── Button Handlers ──────────────────────────────────────────────────────────
func _on_attack_pressed() -> void:
	action_requested.emit(BattleEnums.CommandType.ATTACK)

func _on_skill_pressed() -> void:
	action_requested.emit(BattleEnums.CommandType.SKILL)

func _on_guard_pressed() -> void:
	action_requested.emit(BattleEnums.CommandType.GUARD)

func _on_item_pressed() -> void:
	action_requested.emit(BattleEnums.CommandType.ITEM)

func _on_flee_pressed() -> void:
	action_requested.emit(BattleEnums.CommandType.FLEE)

# ─── Private ──────────────────────────────────────────────────────────────────
func _refresh_item_button() -> void:
	var inventory := InventoryManager.new()
	var usable := inventory.get_usable_items_in_battle()
	item_button.disabled = usable.is_empty()
