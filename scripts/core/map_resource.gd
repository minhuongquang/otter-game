class_name MapResource
extends Resource

## Data for exploration maps.

@export var map_id: String = ""
@export var display_name: String = ""
@export var scene_path: String = ""
@export var enemy_groups: Array[Dictionary] = []
@export var encounter_rate: float = 0.01
@export var connections: Array[Dictionary] = []
@export var ambient_bgm: AudioStream = null
@export var ambient_sfx: AudioStream = null
@export var camera_limits: Rect2 = Rect2(0, 0, 1920, 1080)
