class_name QuestResource
extends Resource

## Data for quest definitions.

@export var quest_id: String = ""
@export var title: String = ""
@export var description: String = ""
@export var quest_type: String = "side"
@export var prerequisites: Array[String] = []
@export var stages: Array[Resource] = []
@export var experience_reward: int = 0
@export var currency_reward: int = 0
@export var item_rewards: Array[String] = []
@export var failure_conditions: Array[Dictionary] = []
@export var on_start_events: Array[Dictionary] = []
@export var on_complete_events: Array[Dictionary] = []

class QuestStage:
	extends Resource

	var stage_id: String = ""
	var description: String = ""
	var objectives: Array[Dictionary] = []
	var on_enter_events: Array[Dictionary] = []
	var on_exit_events: Array[Dictionary] = []
