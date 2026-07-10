## InventoryDetail — shows selected item's description and stats.
class_name InventoryDetail
extends Panel

# ─── @onready ─────────────────────────────────────────────────────────────────
@onready var item_name_label: Label = %ItemNameLabel
@onready var description_label: Label = %DescriptionLabel
@onready var stats_label: Label = %StatsLabel
@onready var type_label: Label = %TypeLabel

# ─── Public API ───────────────────────────────────────────────────────────────
func show_item(item_res: ItemResource) -> void:
	item_name_label.text = item_res.item_name
	description_label.text = item_res.description

	var type_str := ""
	match item_res.item_type:
		ItemResource.ItemType.CONSUMABLE:
			type_str = "Consumable"
		ItemResource.ItemType.EQUIPMENT:
			type_str = "Equipment"
		ItemResource.ItemType.KEY_ITEM:
			type_str = "Key Item"
		ItemResource.ItemType.MATERIAL:
			type_str = "Material"
		ItemResource.ItemType.TREASURE:
			type_str = "Treasure"
	type_label.text = type_str

	var stats_lines: Array[String] = []
	if item_res.item_type == ItemResource.ItemType.EQUIPMENT:
		stats_lines.append("Slot: %s" % str(item_res.equip_slot))
		for stat_name: String in item_res.stat_bonuses:
			stats_lines.append("+%d %s" % [item_res.stat_bonuses[stat_name], stat_name.capitalize().replace("_", " ")])
	elif item_res.item_type == ItemResource.ItemType.CONSUMABLE:
		for effect: ItemEffect in item_res.consumable_effects:
			var desc := _describe_effect(effect)
			if desc != "":
				stats_lines.append(desc)
	stats_label.text = "\n".join(stats_lines)

func clear() -> void:
	item_name_label.text = ""
	description_label.text = ""
	stats_label.text = ""
	type_label.text = ""

# ─── Private ──────────────────────────────────────────────────────────────────
func _describe_effect(effect: ItemEffect) -> String:
	match effect.effect_type:
		ItemEffect.EffectType.HEAL_HP:
			return "Restores %d HP" % effect.value
		ItemEffect.EffectType.HEAL_SP:
			return "Restores %d SP" % effect.value
		ItemEffect.EffectType.CURE_STATUS:
			return "Cures %s" % str(effect.status_type).capitalize()
	return ""