## EnemyPanel — horizontal list of enemy StatBars. Self-subscribes to EventBus.
class_name EnemyPanel
extends HBoxContainer

# ─── Constants ────────────────────────────────────────────────────────────────
const STAT_BAR_SCENE := preload("res://scenes/ui/stat_bar.tscn")

# ─── State ────────────────────────────────────────────────────────────────────
var _bars: Dictionary = {}  # BattleActor → StatBar

# ─── Lifecycle ────────────────────────────────────────────────────────────────
func _ready() -> void:
	EventBus.listen("damage_dealt", _on_damage_dealt)
	EventBus.listen("actor_died", _on_actor_died)

func _exit_tree() -> void:
	EventBus.unlisten("damage_dealt", _on_damage_dealt)
	EventBus.unlisten("actor_died", _on_actor_died)

# ─── Public API ───────────────────────────────────────────────────────────────
func set_enemies(actors: Array[BattleActor]) -> void:
	_clear()
	for actor: BattleActor in actors:
		var bar := _create_bar(actor)
		add_child(bar)
		_bars[actor] = bar

func refresh_all() -> void:
	for bar: StatBar in _bars.values():
		bar.refresh()

# ─── EventBus Handlers ────────────────────────────────────────────────────────
func _on_damage_dealt(data: Dictionary) -> void:
	_refresh_target(data.get("target_id", ""))

func _on_actor_died(data: Dictionary) -> void:
	_refresh_target(data.get("actor_id", ""))

# ─── Private ──────────────────────────────────────────────────────────────────
func _create_bar(actor: BattleActor) -> StatBar:
	var bar: StatBar = STAT_BAR_SCENE.instantiate()
	bar.set_actor(actor)
	return bar

func _clear() -> void:
	for child in get_children():
		child.queue_free()
	_bars.clear()

func _refresh_target(actor_id: String) -> void:
	for actor: BattleActor in _bars.keys():
		if actor.actor_id == actor_id:
			_bars[actor].refresh()
			return