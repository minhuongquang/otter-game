## StatBar — reusable HP/SP bar for a single BattleActor.
class_name StatBar
extends MarginContainer

# ─── @onready ─────────────────────────────────────────────────────────────────
@onready var name_label: Label = %NameLabel
@onready var hp_bar: ProgressBar = %HPBar
@onready var hp_text: Label = %HPText
@onready var sp_bar: ProgressBar = %SPBar
@onready var sp_text: Label = %SPText

# ─── State ────────────────────────────────────────────────────────────────────
var actor: BattleActor = null

# ─── Public API ───────────────────────────────────────────────────────────────
func set_actor(p_actor: BattleActor) -> void:
	actor = p_actor
	refresh()

func refresh() -> void:
	if actor == null:
		hide()
		return
	show()
	name_label.text = actor.display_name
	hp_bar.max_value = actor.get_max_hp()
	hp_bar.value = actor.current_hp
	hp_text.text = "%d/%d" % [actor.current_hp, actor.get_max_hp()]
	sp_bar.max_value = actor.get_max_sp()
	sp_bar.value = actor.current_sp
	sp_text.text = "%d/%d" % [actor.current_sp, actor.get_max_sp()]

func clear() -> void:
	actor = null
	hide()