class_name CharacterResource
extends Resource

## Data for playable characters and major NPCs.

@export var character_id: String = ""
@export var display_name: String = ""
@export var portrait: Texture2D = null
@export var sprite: Texture2D = null
@export var battle_sprite: Texture2D = null
@export var base_stats: StatsResource = null
@export var description: String = ""
@export var starting_skills: Array[Resource] = []
