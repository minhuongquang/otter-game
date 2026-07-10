## PartyState — persistent runtime holder for party data between scenes.
## Written by battle lifecycle handlers after every battle.
## Read/written by SaveManager during save/load.
## Apply snapshots via PartyState.apply_to() before starting a battle.
##
## Owns: battle snapshots (HP/SP), character progression (EXP/Level),
##       inventory (item quantities), equipment (slot mappings), gold.
extends Node

# ─── Signals ──────────────────────────────────────────────────────────────────
signal item_added(item_id: StringName, quantity: int)
signal item_removed(item_id: StringName, quantity: int)
signal item_equipped(character_id: String, slot: StringName, item_id: StringName)
signal item_unequipped(character_id: String, slot: StringName)
signal currency_changed(old_value: int, new_value: int)

# ─── Battle Snapshots ─────────────────────────────────────────────────────────
## Persistent party runtime state.
## Each entry: { character_id: String, current_hp: int, current_sp: int }
var snapshots: Array[Dictionary] = []

## Apply saved HP/SP to an array of BattleActors.
## Matches by actor_id. Actors not found in snapshots keep their defaults.
func apply_to(party: Array[BattleActor]) -> void:
	for actor in party:
		for snap in snapshots:
			if snap.get("character_id", "") == actor.actor_id:
				actor.current_hp = snap.get("current_hp", actor.current_hp)
				actor.current_sp = snap.get("current_sp", actor.current_sp)
				break

# ─── Character Progression ────────────────────────────────────────────────────
## Persistent character EXP and level.
## { "hero": { "exp": 150, "level": 3 }, ... }
var character_progression: Dictionary = {}

func get_exp(character_id: String) -> int:
	if character_progression.has(character_id):
		return character_progression[character_id].get("exp", 0)
	return 0

func set_exp(character_id: String, amount: int) -> void:
	if not character_progression.has(character_id):
		character_progression[character_id] = {}
	character_progression[character_id]["exp"] = maxi(0, amount)

func add_exp(character_id: String, amount: int) -> void:
	set_exp(character_id, get_exp(character_id) + amount)

func get_level(character_id: String) -> int:
	if character_progression.has(character_id):
		return character_progression[character_id].get("level", 1)
	return 1

func set_level(character_id: String, level: int) -> void:
	if not character_progression.has(character_id):
		character_progression[character_id] = {}
	character_progression[character_id]["level"] = maxi(1, level)

# ─── Inventory ────────────────────────────────────────────────────────────────
## Owned items and quantities. { "potion": 3, "iron_sword": 1, ... }
## Inventory represents ownership. Equipped items remain in this dict.
var inventory: Dictionary = {}

func add_item(item_id: StringName, quantity: int = 1) -> bool:
	if quantity <= 0:
		return false
	var key := StringName(item_id)
	var current: int = inventory.get(key, 0)
	inventory[key] = current + quantity
	item_added.emit(item_id, quantity)
	return true

func remove_item(item_id: StringName, quantity: int = 1) -> bool:
	if quantity <= 0:
		return false
	var key := StringName(item_id)
	var current: int = inventory.get(key, 0)
	if current < quantity:
		return false
	inventory[key] = current - quantity
	if inventory[key] <= 0:
		inventory.erase(key)
	item_removed.emit(item_id, quantity)
	return true

func get_item_count(item_id: StringName) -> int:
	return inventory.get(StringName(item_id), 0)

func has_item(item_id: StringName) -> bool:
	return get_item_count(item_id) > 0

# ─── Gold ─────────────────────────────────────────────────────────────────────
var gold: int = 0

func get_gold() -> int:
	return gold

func set_gold(amount: int) -> void:
	var old := gold
	gold = maxi(0, amount)
	currency_changed.emit(old, gold)

func add_gold(amount: int) -> void:
	set_gold(gold + amount)

func remove_gold(amount: int) -> bool:
	if gold < amount:
		return false
	set_gold(gold - amount)
	return true

# ─── Equipment ────────────────────────────────────────────────────────────────
## Equipment mappings. { "hero": { "weapon": "iron_sword", "body": "", "off_hand": "" }, ... }
## References item_ids owned in inventory. Does not track quantities.
var equipment: Dictionary = {}

func equip_item(character_id: String, slot: StringName, item_id: StringName) -> bool:
	if not has_item(item_id):
		return false
	if not equipment.has(character_id):
		equipment[character_id] = {}
	# unequip current item in that slot first (no-op if empty)
	var current_item: StringName = equipment[character_id].get(StringName(slot), &"")
	if current_item != &"":
		_remove_equip_slot(character_id, slot)
	equipment[character_id][StringName(slot)] = item_id
	item_equipped.emit(character_id, slot, item_id)
	return true

func unequip_item(character_id: String, slot: StringName) -> bool:
	if not equipment.has(character_id):
		return false
	if not equipment[character_id].has(StringName(slot)):
		return false
	var item_id: StringName = equipment[character_id][StringName(slot)]
	if item_id == &"":
		return false
	_remove_equip_slot(character_id, slot)
	item_unequipped.emit(character_id, slot)
	return true

func _remove_equip_slot(character_id: String, slot: StringName) -> void:
	equipment[character_id].erase(StringName(slot))
	if equipment[character_id].is_empty():
		equipment.erase(character_id)

func get_equipped(character_id: String, slot: StringName) -> StringName:
	if not equipment.has(character_id):
		return &""
	return equipment[character_id].get(StringName(slot), &"")

func is_equipped(character_id: String, item_id: StringName) -> bool:
	if not equipment.has(character_id):
		return false
	for slot_value: StringName in equipment[character_id].values():
		if slot_value == item_id:
			return true
	return false

## Sum all stat bonuses from all equipped items for a character.
## Returns { "attack": 5, "defense": 8, ... }
func get_equipment_bonuses(character_id: String) -> Dictionary:
	var bonuses: Dictionary = {}
	if not equipment.has(character_id):
		return bonuses
	for item_id: StringName in equipment[character_id].values():
		if item_id == &"":
			continue
		var item_res := _resolve_item(item_id)
		if item_res == null or item_res.item_type != ItemResource.ItemType.EQUIPMENT:
			continue
		for stat_name: String in item_res.stat_bonuses:
			var bonus_value = item_res.stat_bonuses[stat_name]
			bonuses[stat_name] = bonuses.get(stat_name, 0) + int(bonus_value)
	return bonuses

# ─── Equipment Slots Reference ────────────────────────────────────────────────
## Which slots a character supports. Hardcoded for prototype.
func get_slots_for_character(_character_id: String) -> Array[StringName]:
	return [&"weapon", &"body", &"off_hand"]

# ─── Private Helpers ──────────────────────────────────────────────────────────
func _resolve_item(item_id: StringName) -> ItemResource:
	if not has_node("/root/Database"):
		return null
	var db := get_node("/root/Database")
	var res: Resource = db.get_item(str(item_id))
	if res is ItemResource:
		return res
	return null