class_name QuestResource
extends Resource

## Defines a complete quest with stages, objectives, and rewards.

enum QuestType { MAIN, SIDE }

@export var quest_id: String = ""
@export var title: String = ""
@export var description: String = ""
@export var icon: Texture2D = null
@export var quest_type: QuestType = QuestType.SIDE
@export var repeatable: bool = false
@export var auto_accept: bool = false
@export var auto_complete: bool = false
@export var prerequisites: Array[String] = []
@export var stages: Array[QuestStageResource] = []
@export var rewards: Dictionary = {}