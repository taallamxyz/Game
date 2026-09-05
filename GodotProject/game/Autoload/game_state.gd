extends Node

var coins: int = 0
var health: int = 100
var max_health: int = 100

var last_scene_path: String = ""
var pending_spawn: bool = false

func set_last_scene(path: String) -> void:
	last_scene_path = path
	pending_spawn = true

func clear_pending_spawn() -> void:
	pending_spawn = false

func reset() -> void:
	coins = 0
	health = 100
	max_health = 100
	last_scene_path = ""
	pending_spawn = false
