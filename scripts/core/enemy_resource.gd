class_name EnemyResource
extends Resource

## Data for enemy encounters in battle.

@export var enemy_id: String = ""
@export var display_name: String = ""
@export var sprite: Texture2D = null
@export var stats: StatsResource = null
@export var skills: Array[Resource] = []
@export var exp_reward: int = 0
@export var item_drops: Array[Dictionary] = []
@export var element: String = "neutral"
@export var ai_type: String = "basic"
