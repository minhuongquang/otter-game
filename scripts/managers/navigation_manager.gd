class_name NavigationManager
extends Node

## Manages world navigation state, region unlock logic, and scene transitions.
## Designed to be attached to a WorldMap scene or loaded as needed.
##
## Responsibilities:
## - Track current region, building, and previous navigation state
## - Validate unlock conditions for regions, buildings, and connections
## - Set story progress flags on first region entry
## - Emit navigation events for other systems to react to
##
## Usage:
##   var nav: NavigationManager = $NavigationManager
##   if nav.select_region("verdant_plains"):
##       nav.enter_region("verdant_plains")

# === Signals ===
signal region_selected(region_id: String)
signal region_entered(region_id: String)
signal region_exited(from_region: String, to_region: String)
signal building_entered(building_id: String, region_id: String)
signal building_exited(building_id: String, region_id: String)
signal navigation_blocked(target_id: String, reason: String)

# === State ===
var current_region_id: String = ""
var current_building_id: String = ""
var previous_region_id: String = ""

# === Public Methods ===

## Select a region on the world map. Checks unlock conditions.
## Returns true if the region is accessible.
func select_region(region_id: String) -> bool:
	var region: RegionResource = Database.get_region(region_id) as RegionResource
	if region == null:
		push_error("NavigationManager: Region not found: %s" % region_id)
		return false
	
	if not _is_region_unlocked(region):
		var reason: String = _get_unlock_reason(region)
		navigation_blocked.emit(region_id, reason)
		EventBus.emit_event("navigation_blocked", {
			"target_id": region_id,
			"target_type": "region",
			"reason": reason,
			"display_name": region.display_name
		})
		return false
	
	region_selected.emit(region_id)
	EventBus.emit_event("region_selected", {"region_id": region_id})
	return true

## Enter a region. Called when the player confirms selection.
## Triggers story progress and scene transition.
func enter_region(region_id: String) -> void:
	var region: RegionResource = Database.get_region(region_id) as RegionResource
	if region == null:
		return
	
	previous_region_id = current_region_id
	current_region_id = region_id
	current_building_id = ""
	
	# Set story progress flag on first entry
	if region.story_flag and not region.story_flag.is_empty():
		if not GlobalFlags.has_flag(region.story_flag):
			GlobalFlags.set_flag(region.story_flag, true)
			EventBus.emit_event("story_progressed", {
				"flag": region.story_flag,
				"region_id": region_id,
				"display_name": region.display_name
			})
	
	region_entered.emit(region_id)
	EventBus.emit_event("region_entered", {
		"region_id": region_id,
		"previous_region": previous_region_id
	})
	
	# Play ambient audio if defined
	if region.ambient_bgm:
		EventBus.emit_event("play_bgm", {"stream": region.ambient_bgm})
	if region.ambient_sfx:
		EventBus.emit_event("play_ambient_sfx", {"stream": region.ambient_sfx})

## Exit the current region. Returns to world map.
func exit_region() -> void:
	if current_region_id.is_empty():
		return
	
	var from_region: String = current_region_id
	current_region_id = ""
	current_building_id = ""
	
	region_exited.emit(from_region, "")
	EventBus.emit_event("region_exited", {
		"from": from_region,
		"to": ""
	})

## Enter a building within the current region.
## Returns true if the building is accessible and unlocked.
func enter_building(building_id: String) -> bool:
	if current_region_id.is_empty():
		push_warning("NavigationManager: No region selected to enter building: %s" % building_id)
		return false
	
	var region: RegionResource = Database.get_region(current_region_id) as RegionResource
	if region == null:
		return false
	
	# Find the building entry
	var building: BuildingEntry = null
	for b: BuildingEntry in region.buildings:
		if b.building_id == building_id:
			building = b
			break
	
	if building == null:
		push_error("NavigationManager: Building %s not found in region %s" % [building_id, current_region_id])
		return false
	
	# Check unlock condition
	if not building.required_flag.is_empty():
		if not GlobalFlags.get_flag(building.required_flag, false):
			var reason: String = "Requires flag: %s" % building.required_flag
			navigation_blocked.emit(building_id, reason)
			EventBus.emit_event("navigation_blocked", {
				"target_id": building_id,
				"target_type": "building",
				"reason": reason,
				"display_name": building.display_name
			})
			return false
	
	current_building_id = building_id
	
	building_entered.emit(building_id, current_region_id)
	EventBus.emit_event("building_entered", {
		"building_id": building_id,
		"region_id": current_region_id,
		"building_type": building.building_type
	})
	return true

## Exit the current building. Returns to region hub.
func exit_building() -> void:
	if current_building_id.is_empty():
		return
	
	var building_id: String = current_building_id
	current_building_id = ""
	
	building_exited.emit(building_id, current_region_id)
	EventBus.emit_event("building_exited", {
		"building_id": building_id,
		"region_id": current_region_id
	})

## Travel to another region via a connection path.
func travel_to(region_id: String) -> bool:
	if not select_region(region_id):
		return false
	
	var old_region: String = current_region_id
	enter_region(region_id)
	
	if not old_region.is_empty():
		region_exited.emit(old_region, region_id)
		EventBus.emit_event("region_exited", {
			"from": old_region,
			"to": region_id
		})
	return true

## Check if a region is unlocked for the current game state.
func is_region_unlocked(region_id: String) -> bool:
	var region: RegionResource = Database.get_region(region_id) as RegionResource
	if region == null:
		return false
	return _is_region_unlocked(region)

## Get all unlocked regions.
func get_unlocked_regions() -> Array[RegionResource]:
	var all_regions: Array = Database.get_all_regions()
	var result: Array[RegionResource] = []
	
	for r in all_regions:
		var region: RegionResource = r as RegionResource
		if region and _is_region_unlocked(region):
			result.append(region)
	
	return result

## Get all regions (including locked).
func get_all_regions() -> Array[RegionResource]:
	var all_regions: Array = Database.get_all_regions()
	var result: Array[RegionResource] = []
	
	for r in all_regions:
		var region: RegionResource = r as RegionResource
		if region:
			result.append(region)
	
	return result

## Get buildings for the current region.
func get_current_region_buildings() -> Array[BuildingEntry]:
	var region: RegionResource = get_current_region()
	if region == null:
		return []
	return region.buildings

## Get the current region resource.
func get_current_region() -> RegionResource:
	if current_region_id.is_empty():
		return null
	return Database.get_region(current_region_id) as RegionResource

## Get the current building entry.
func get_current_building() -> BuildingEntry:
	if current_region_id.is_empty() or current_building_id.is_empty():
		return null
	
	var region: RegionResource = get_current_region()
	if region == null:
		return null
	
	for b: BuildingEntry in region.buildings:
		if b.building_id == current_building_id:
			return b
	
	return null

## Get the shop resource for a given building.
func get_shop_for_building(building: BuildingEntry) -> ShopResource:
	if building.shop_id.is_empty():
		return null
	return Database.get_shop(building.shop_id) as ShopResource

## Get NPC IDs for a specific building or the current region.
func get_npcs(building_id: String = "") -> Array[String]:
	if not building_id.is_empty():
		var region: RegionResource = get_current_region()
		if region == null:
			return []
		for b: BuildingEntry in region.buildings:
			if b.building_id == building_id:
				return b.npc_ids
		return []
	
	var region: RegionResource = get_current_region()
	if region == null:
		return []
	return region.npc_ids

## Get unlocked connections from the current region.
func get_open_connections() -> Array[RegionConnection]:
	var region: RegionResource = get_current_region()
	if region == null:
		return []
	
	var result: Array[RegionConnection] = []
	for conn: RegionConnection in region.connections:
		if _is_connection_open(conn):
			result.append(conn)
	
	return result

## Reset navigation state (e.g., on new game, game over).
func reset() -> void:
	current_region_id = ""
	current_building_id = ""
	previous_region_id = ""

# === Private Methods ===

## Check if a region is unlocked based on flags and quests.
func _is_region_unlocked(region: RegionResource) -> bool:
	if region.required_flag and not region.required_flag.is_empty():
		if not GlobalFlags.get_flag(region.required_flag, false):
			return false
	
	if region.required_quest and not region.required_quest.is_empty():
		if not GlobalFlags.get_flag("quest_completed_" + region.required_quest, false):
			return false
	
	return true

## Get the reason a region is locked (for UI display).
func _get_unlock_reason(region: RegionResource) -> String:
	if region.required_flag and not region.required_flag.is_empty():
		if not GlobalFlags.get_flag(region.required_flag, false):
			return "LOCKED: Progress the story to unlock this region."
	
	if region.required_quest and not region.required_quest.is_empty():
		if not GlobalFlags.get_flag("quest_completed_" + region.required_quest, false):
			return "LOCKED: Complete '%s' to unlock this region." % region.required_quest
	
	return "LOCKED"

## Check if a connection is open.
func _is_connection_open(conn: RegionConnection) -> bool:
	if conn.required_flag and not conn.required_flag.is_empty():
		if not GlobalFlags.get_flag(conn.required_flag, false):
			return false
	
	if conn.required_quest and not conn.required_quest.is_empty():
		if not GlobalFlags.get_flag("quest_completed_" + conn.required_quest, false):
			return false
	
	return true