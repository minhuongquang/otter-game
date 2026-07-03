class_name DialogueResource
extends Resource

## Data for dialogue sequences and branching VN content.

@export var dialogue_id: String = ""
@export var background: Texture2D = null
@export var lines: Array[Resource] = []
@export var on_start_events: Array[Dictionary] = []
@export var on_end_events: Array[Dictionary] = []

class DialogueLine:
	extends Resource

	var speaker_id: String = ""
	var text: String = ""
	var emotion: String = "neutral"
	var next_line: String = ""
	var conditions: Array[Dictionary] = []
	var on_display_events: Array[Dictionary] = []

class DialogueChoice:
	extends Resource

	var text: String = ""
	var target_line: String = ""
	var conditions: Array[Dictionary] = []
	var effects: Array[Dictionary] = []
