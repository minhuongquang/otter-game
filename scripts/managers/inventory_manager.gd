## InventoryManager — stateless helper for inventory operations.
## All persistent state lives in PartyState.
## Instantiate via InventoryManager.new() where needed.
class_name InventoryManager
extends RefCounted

# ─── Item Usage ───────────────────────────────────────────────────────────────
## Apply consumable effects to a target BattleActor.
## Returns true if item was consumed successfully.
func use_item(item_id: StringName, target: BattleActor) -> bool:
	if not PartyState.has_item(item_id):
		return false
	if not can_use_item(item_id, target):
		return false

	var item_res := _resolve_item(item_id)
	if item_res == null:
		return false

	for effect: ItemEffect in item_res.consumable_effects:
		_apply_effect(effect, target)

	PartyState.remove_item(item_id, 1)
	EventBus.emit_event("item_used", {"item_id": str(item_id), "target_id": target.actor_id})
	return true

## Use an item outside battle — applies to first alive party member.
## Returns true if consumed.
func use_item_map(item_id: StringName) -> bool:
	if not PartyState.has_item(item_id):
		return false

	var item_res := _resolve_item(item_id)
	if item_res == null:
		return false

	var target_id := _find_first_alive_party_member()
	if target_id == "":
		return false

	for effect: ItemEffect in item_res.consumable_effects:
		_apply_effect_to_snapshot(effect, target_id)

	PartyState.remove_item(item_id, 1)
	EventBus.emit_event("item_used", {"item_id": str(item_id), "target_id": target_id})
	return true

# ─── Validation ───────────────────────────────────────────────────────────────
## Whether this item can be used on this actor.
func can_use_item(item_id: StringName, target: BattleActor) -> bool:
	if not PartyState.has_item(item_id):
		return false
	if target == null:
		return false
	if target.is_defeated():
		return false

	var item_res := _resolve_item(item_id)
	if item_res == null:
		return false
	if item_res.item_type != ItemResource.ItemType.CONSUMABLE:
		return false

	var any_applicable := false
	for effect: ItemEffect in item_res.consumable_effects:
		if _is_effect_applicable(effect, target):
			any_applicable = true
			break
	return any_applicable

## Whether this item can be equipped on this character.
func can_equip_item(character_id: String, item_id: StringName) -> bool:
	if not PartyState.has_item(item_id):
		return false

	var item_res := _resolve_item(item_id)
	if item_res == null:
		return false
	if item_res.item_type != ItemResource.ItemType.EQUIPMENT:
		return false
	if item_res.equip_slot == &"":
		return false

	var slots: Array = PartyState.get_slots_for_character(character_id)
	if not item_res.equip_slot in slots:
		return false

	return true

# ─── Equipment ────────────────────────────────────────────────────────────────
## Equip an owned item onto a character slot.
func equip_item(character_id: String, item_id: StringName) -> bool:
	if not can_equip_item(character_id, item_id):
		return false
	var item_res := _resolve_item(item_id)
	if item_res == null:
		return false
	return PartyState.equip_item(character_id, item_res.equip_slot, item_id)

## Unequip a slot from a character.
func unequip_item(character_id: String, slot: StringName) -> bool:
	return PartyState.unequip_item(character_id, slot)

# ─── Queries ──────────────────────────────────────────────────────────────────
func get_all_items() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for item_id in PartyState.inventory:
		var qty: int = PartyState.inventory[item_id]
		result.append({"item_id": item_id, "quantity": qty})
	return result

func get_items_by_type(item_type: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for item_id in PartyState.inventory:
		var item_res := _resolve_item(item_id)
		if item_res == null:
			continue
		if item_res.item_type == item_type:
			var qty: int = PartyState.inventory[item_id]
			result.append({"item_id": item_id, "quantity": qty})
	return result

func get_usable_items_in_battle() -> Array[Dictionary]:
	return get_items_by_type(ItemResource.ItemType.CONSUMABLE)

func get_item_resource(item_id: StringName) -> ItemResource:
	return _resolve_item(item_id)

# ─── Private ──────────────────────────────────────────────────────────────────
func _resolve_item(item_id: StringName) -> ItemResource:
	var res: Resource = Database.get_item(str(item_id))
	if res is ItemResource:
		return res
	return null

func _apply_effect(effect: ItemEffect, target: BattleActor) -> void:
	match effect.effect_type:
		ItemEffect.EffectType.HEAL_HP:
			target.heal(effect.value)
		ItemEffect.EffectType.HEAL_SP:
			target.restore_sp(effect.value)
		ItemEffect.EffectType.CURE_STATUS:
			if effect.status_type != &"":
				target.remove_status(_status_type_from_string(effect.status_type))

func _apply_effect_to_snapshot(effect: ItemEffect, character_id: String) -> void:
	for snap in PartyState.snapshots:
		if snap.get("character_id", "") == character_id:
			match effect.effect_type:
				ItemEffect.EffectType.HEAL_HP:
					var max_hp := _get_character_max_hp(character_id)
					snap["current_hp"] = mini(snap.get("current_hp", 0) + effect.value, max_hp)
				ItemEffect.EffectType.HEAL_SP:
					var max_sp := _get_character_max_sp(character_id)
					snap["current_sp"] = mini(snap.get("current_sp", 0) + effect.value, max_sp)
				ItemEffect.EffectType.CURE_STATUS:
					pass
			break

func _get_character_max_hp(character_id: String) -> int:
	var res: Resource = Database.get_character(character_id)
	if res is CharacterResource and res.base_stats:
		return res.base_stats.max_hp
	return 9999

func _get_character_max_sp(character_id: String) -> int:
	var res: Resource = Database.get_character(character_id)
	if res is CharacterResource and res.base_stats:
		return res.base_stats.max_sp
	return 9999

func _find_first_alive_party_member() -> String:
	for snap in PartyState.snapshots:
		if snap.get("current_hp", 0) > 0:
			return snap.get("character_id", "")
	return ""

func _is_effect_applicable(effect: ItemEffect, target: BattleActor) -> bool:
	match effect.effect_type:
		ItemEffect.EffectType.HEAL_HP:
			return target.current_hp < target.get_max_hp()
		ItemEffect.EffectType.HEAL_SP:
			return target.current_sp < target.get_max_sp()
		ItemEffect.EffectType.CURE_STATUS:
			return target.has_status(_status_type_from_string(effect.status_type))
	return false

func _status_type_from_string(status_str: StringName) -> StatusEffect.Type:
	match str(status_str).to_lower():
		"poison":
			return StatusEffect.Type.POISON
		"sleep":
			return StatusEffect.Type.SLEEP
		"burn":
			return StatusEffect.Type.BURN
		_:
			return StatusEffect.Type.POISON