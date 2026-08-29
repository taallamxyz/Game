extends Area3D

@export_file("*.tscn") var target_scene: String = ""
@export var require_interact: bool = false
@export var prompt_text: String = "E"

var _player_in_range: bool = false

@onready var _prompt: Label3D = $Prompt if has_node("Prompt") else null

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	# Ensure we detect CharacterBody3D on layer 1
	collision_layer = 0
	collision_mask = 1
	monitoring = true
	monitorable = true
	if _prompt:
		_prompt.visible = false
		_prompt.billboard = 1
		_prompt.text = prompt_text

func _on_body_entered(body: Node3D) -> void:
	if not body.is_in_group("player"):
		return
	_player_in_range = true
	if require_interact:
		if _prompt:
			_prompt.visible = true
	else:
		_change_scene()

func _on_body_exited(body: Node3D) -> void:
	if not body.is_in_group("player"):
		return
	_player_in_range = false
	if _prompt:
		_prompt.visible = false

func _unhandled_input(event: InputEvent) -> void:
	if require_interact and _player_in_range and event.is_action_pressed("interact"):
		_change_scene()
		get_viewport().set_input_as_handled()

func _change_scene() -> void:
	if target_scene == "":
		push_warning("Door target_scene not set on %s" % name)
		return
	get_tree().change_scene_to_file(target_scene)
