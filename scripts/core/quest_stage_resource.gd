class_name QuestStageResource
extends Resource

## Defines one stage within a quest. A quest with 3 stages has 3 entries.

@export var stage_id: String = ""
@export var description: String = ""
@export var objectives: Array[QuestObjectiveResource] = []