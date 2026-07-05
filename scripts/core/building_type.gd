class_name BuildingType
extends Resource

## Enum for building types in world navigation.
## Determines the interaction available when entering a building.

enum Type {
	TOWN_ENTRY,     # Transition from world map to region hub
	INN,            # Rest, save, recover HP/SP
	SHOP,           # Buy/sell items
	GUILD,          # Quest hub, bounty board
	BLACKSMITH,     # Equipment upgrade, crafting
	TEMPLE,         # Save, heal, story events
	HOUSE,          # NPC residence, side quests
	DUNGEON_ENTRY,  # Leads to exploration map
	GATE,           # Leads to another region
	SPECIAL         # Story-specific, one-off
}
