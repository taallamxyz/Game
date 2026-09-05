extends Area3D

@export_file("*.tscn") var target_scene: String = ""
@export var require_interact: bool = false
@export var prompt_text: String = "E"

var _player_in_range: bool = false
var _is_transitioning: bool = false

@onready var _prompt: Label3D = $Prompt if has_node("Prompt") else null

var _joypad_prompt := "✕"
var _keyboard_prompt := ""

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	# Ensure we detect CharacterBody3D on layer 1
	collision_layer = 0
	collision_mask = 1
	monitoring = true
	monitorable = true
	_keyboard_prompt = prompt_text
	# Joypad prompt: E -> ✕, otherwise prepend ✕ to custom text (e.g. SHOP -> ✕ SHOP)
	if prompt_text == "E":
		_joypad_prompt = "✕"
	elif prompt_text == "":
		_joypad_prompt = "✕"
	else:
		_joypad_prompt = "✕ " + prompt_text
	_update_prompt_text()
	if _prompt:
		_prompt.visible = false
		_prompt.billboard = 1
	# Update prompt when joypad connects/disconnects (PS4 DualShock 4)
	Input.joy_connection_changed.connect(_on_joy_connection_changed)

func _update_prompt_text() -> void:
	if _prompt == null:
		return
	var use_joypad := Input.get_connected_joypads().size() > 0
	_prompt.text = _joypad_prompt if use_joypad else _keyboard_prompt


func _on_joy_connection_changed(_device: int, _connected: bool) -> void:
	_update_prompt_text()


func _on_body_entered(body: Node3D) -> void:
	if not body.is_in_group("player"):
		return
	_player_in_range = true
	_update_prompt_text()
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
	if _is_transitioning:
		return
	_is_transitioning = true


	var gs := get_node_or_null("/root/GameState")
	if gs:
		var player := get_tree().get_first_node_in_group("player") as Node3D
		if player:
			gs.coins = player.get("coins") if "coins" in player else gs.coins
			gs.health = player.get("health") if "health" in player else gs.health
			gs.max_health = player.get("max_health") if "max_health" in player else gs.max_health
		# Store source scene for dynamic SpawTarget lookup in target scene
		var from_path := get_tree().current_scene.scene_file_path if get_tree().current_scene else ""
		gs.set_last_scene(from_path)

	# Prefer cinematic autoload, fallback to instant
	if has_node("/root/SceneTransition") and get_node("/root/SceneTransition").has_method("change_scene"):
		await get_node("/root/SceneTransition").change_scene(target_scene, 0.45)
		_is_transitioning = false
	else:
		get_tree().change_scene_to_file(target_scene)


