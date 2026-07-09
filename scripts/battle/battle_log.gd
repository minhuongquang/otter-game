## BattleLog — scrollable text log. Self-subscribes to EventBus.
class_name BattleLog
extends Panel

# ─── @onready ─────────────────────────────────────────────────────────────────
@onready var text_label: RichTextLabel = %TextLabel

# ─── Lifecycle ────────────────────────────────────────────────────────────────
func _ready() -> void:
	EventBus.listen("damage_dealt", _on_damage_dealt)
	EventBus.listen("actor_died", _on_actor_died)
	EventBus.listen("command_executed", _on_command_executed)
	EventBus.listen("turn_started", _on_turn_started)
	EventBus.listen("battle_finished", _on_battle_finished)

func _exit_tree() -> void:
	EventBus.unlisten("damage_dealt", _on_damage_dealt)
	EventBus.unlisten("actor_died", _on_actor_died)
	EventBus.unlisten("command_executed", _on_command_executed)
	EventBus.unlisten("turn_started", _on_turn_started)
	EventBus.unlisten("battle_finished", _on_battle_finished)

# ─── Public API ───────────────────────────────────────────────────────────────
func add_entry(p_text: String, p_color: Color = Color.WHITE) -> void:
	text_label.push_color(p_color)
	text_label.append_text(p_text + "\n")
	text_label.pop()

func clear_log() -> void:
	text_label.clear()

# ─── EventBus Handlers ────────────────────────────────────────────────────────
func _on_damage_dealt(data: Dictionary) -> void:
	var target_id: String = data.get("target_id", "?")
	var dmg: int = data.get("damage", 0)
	add_entry("%s takes %d damage." % [target_id, dmg])

func _on_actor_died(data: Dictionary) -> void:
	var display_name: String = data.get("display_name", "?")
	add_entry("%s is defeated!" % display_name, Color.ORANGE_RED)

func _on_command_executed(_data: Dictionary) -> void:
	pass  # handled by more specific events

func _on_turn_started(data: Dictionary) -> void:
	var display_name: String = data.get("display_name", "?")
	add_entry("— %s's turn —" % display_name, Color.LIGHT_SKY_BLUE)

func _on_battle_finished(data: Dictionary) -> void:
	var outcome = data.get("outcome", -1)
	match outcome:
		BattleEnums.BattleOutcome.VICTORY:
			add_entry("Victory!", Color.GOLD)
		BattleEnums.BattleOutcome.DEFEAT:
			add_entry("Defeat...", Color.RED)
		_:
			add_entry("Battle ended.", Color.GRAY)