class_name QuestObjectiveResource
extends Resource

## Defines one objective within a quest stage.

enum ObjectiveType { DEFEAT_ENEMY, COLLECT_ITEM, TALK_NPC, VISIT_AREA, REACH_LEVEL }

@export var objective_id: String = ""
@export var description: String = ""
@export var objective_type: ObjectiveType = ObjectiveType.DEFEAT_ENEMY
@export var target_id: String = ""       # enemy_id, item_id, npc_id, or area_id
@export var required_count: int = 1