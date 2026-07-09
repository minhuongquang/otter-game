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
	disable()

# ─── Public API ───────────────────────────────────────────────────────────────
func enable() -> void:
	attack_button.disabled = false

func disable() -> void:
	attack_button.disabled = true
	skill_button.disabled = true
	guard_button.disabled = true
	item_button.disabled = true
	flee_button.disabled = true

# ─── Button Handlers ──────────────────────────────────────────────────────────
func _on_attack_pressed() -> void:
	action_requested.emit(BattleEnums.CommandType.ATTACK)