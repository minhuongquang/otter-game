class_name SkillResource
extends Resource

## Data for usable skills in battle.

@export var skill_id: String = ""
@export var display_name: String = ""
@export var description: String = ""
@export var icon: Texture2D = null
@export var sp_cost: int = 0
@export var power: int = 0
@export var element: String = "neutral"
@export var target_type: String = "single_enemy"
@export var skill_type: String = "physical"
@export var status_effect: String = ""
@export var status_chance: float = 0.0
@export var animation: String = ""
