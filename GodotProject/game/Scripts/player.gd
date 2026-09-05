extends CharacterBody3D

@export var WALK_SPEED := 2.5
@export var RUN_SPEED := 5.0
@export var JUMP_SPEED := 4.5
@export var ACCELERATION := 12.0
@export var ROTATION_SPEED := 10.0
@export var FALL_THRESHOLD := -5.0
@export var max_health := 100
@export var JOYPAD_CAMERA_SENSITIVITY := 2.5
@export var JOYPAD_DEADZONE := 0.15
@export var JOYPAD_Y_INVERT := false

@onready var model: Node3D = $Model
@onready var camera_pivot: Node3D = $CameraPivot
@onready var camera: Camera3D = $CameraPivot/Camera3D
@onready var animation_player: AnimationPlayer = _find_animation_player()

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var animation_state := ""
var camera_pitch := -0.55
var respawn_position := Vector3.ZERO
var health: int = max_health
var coins := 0

signal health_changed(current_health: int, maximum_health: int)
signal coins_changed(amount: int)

func _ready() -> void:
	var gs := get_node_or_null("/root/GameState")
	# Sync coins/health from GameState
	if gs:
		coins = gs.coins
		health = gs.health
		max_health = gs.max_health

	# Dynamic spawn: if we came from another scene via door, teleport to that door's SpawTarget
	if gs and gs.pending_spawn:
		var spawn_transform = _find_spaw_target(gs.last_scene_path)
		if spawn_transform != null:
			global_position = spawn_transform.origin
			# Face away from door (use marker rotation)
			camera_pivot.rotation.y = spawn_transform.basis.get_euler().y
			respawn_position = global_position
			gs.clear_pending_spawn()
		else:
			respawn_position = global_position
			gs.clear_pending_spawn()
	else:
		respawn_position = global_position

	camera.position = Vector3(0.0, 2.2, 5.0)
	camera_pivot.rotation.x = camera_pitch
	camera.current = true

	if animation_player:
		_set_loop("Idle")
		_set_loop("Run")
		_play_animation("Idle")

	health_changed.emit(health, max_health)
	coins_changed.emit(coins)
	# Ensure GameState stays synced
	if gs:
		gs.coins = coins
		gs.health = health
		gs.max_health = max_health

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		camera_pivot.rotation.y -= event.relative.x * 0.003
		camera_pitch = clampf(camera_pitch - event.relative.y * 0.003, -1.1, 0.2)
		camera_pivot.rotation.x = camera_pitch
	elif event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	elif event is InputEventMouseButton and event.pressed:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	elif event.is_action_pressed("test_damage"):
		take_damage(10)
	elif event.is_action_pressed("test_coin"):
		add_coin()

func _physics_process(delta: float) -> void:
	_update_joypad_camera(delta)

	if not is_on_floor():
		velocity.y -= gravity * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		# If an interact was just pressed, prioritize interact over jump (both on Cross/✕ on PS4)
		if Input.is_action_just_pressed("interact") and _is_near_interactable():
			pass
		else:
			velocity.y = JUMP_SPEED

	var input_vector := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var forward := -camera_pivot.global_transform.basis.z
	var right := camera_pivot.global_transform.basis.x
	forward.y = 0.0
	right.y = 0.0
	forward = forward.normalized()
	right = right.normalized()

	var direction := forward * -input_vector.y + right * input_vector.x
	var target_speed := RUN_SPEED if Input.is_action_pressed("run") else WALK_SPEED

	if direction.length_squared() > 0.001:
		direction = direction.normalized()
		var target_velocity := direction * target_speed
		velocity.x = move_toward(velocity.x, target_velocity.x, ACCELERATION * delta)
		velocity.z = move_toward(velocity.z, target_velocity.z, ACCELERATION * delta)

		var target_rotation := atan2(direction.x, direction.z)
		model.rotation.y = lerp_angle(model.rotation.y, target_rotation, ROTATION_SPEED * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, ACCELERATION * delta)
		velocity.z = move_toward(velocity.z, 0.0, ACCELERATION * delta)

	move_and_slide()
	if global_position.y < FALL_THRESHOLD:
		respawn()
	_update_animation()

func respawn() -> void:
	global_position = respawn_position
	velocity = Vector3.ZERO

func take_damage(amount: int) -> void:
	health = maxi(health - amount, 0)
	health_changed.emit(health, max_health)
	var gs := get_node_or_null("/root/GameState")
	if gs:
		gs.health = health

func add_coin(amount: int = 1) -> void:
	coins += amount
	coins_changed.emit(coins)
	var gs := get_node_or_null("/root/GameState")
	if gs:
		gs.coins = coins

func _find_spaw_target(last_scene_path: String):
	# Find door in current scene whose target_scene matches last_scene_path, then return its SpawTarget
	var current_scene := get_tree().current_scene
	if current_scene == null:
		return Transform3D()
	var doors: Array = current_scene.find_children("*", "Area3D", true, false)
	for door in doors:
		if not "target_scene" in door:
			continue
		var target: String = door.get("target_scene")
		var match_found := false
		if target == last_scene_path:
			match_found = true
		elif target != "" and last_scene_path != "":
			# Loose match for uid vs path after Demo->Main rename
			if target.get_file() == last_scene_path.get_file():
				match_found = true
			elif "MainScene" in target and "MainScene" in last_scene_path:
				match_found = true
			elif "ShopScene" in target and "ShopScene" in last_scene_path:
				match_found = true
		if match_found:
			var spaw := door.find_child("SpawTarget", true, false) as Node3D
			if spaw == null:
				spaw = door.find_child("SpawnTarget", true, false) as Node3D
			if spaw:
				return spaw.global_transform
	# Fallback: any SpawTarget in scene (single-door scenes like Shop)
	var fallback := current_scene.find_child("SpawTarget", true, false) as Node3D
	if fallback == null:
		fallback = current_scene.find_child("SpawnTarget", true, false) as Node3D
	if fallback:
		return fallback.global_transform
	return null

func _update_joypad_camera(delta: float) -> void:
	# Right stick (axis 2 = horizontal, 3 = vertical) for camera look - PS4 DualShock 4
	var joy_x := Input.get_joy_axis(0, JOY_AXIS_RIGHT_X)
	var joy_y := Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y)
	if abs(joy_x) < JOYPAD_DEADZONE:
		joy_x = 0.0
	if abs(joy_y) < JOYPAD_DEADZONE:
		joy_y = 0.0
	if joy_x == 0.0 and joy_y == 0.0:
		return
	# Scale by sensitivity and delta; invert Y if requested
	if JOYPAD_Y_INVERT:
		joy_y = -joy_y
	camera_pivot.rotation.y -= joy_x * JOYPAD_CAMERA_SENSITIVITY * delta
	camera_pitch = clampf(camera_pitch - joy_y * JOYPAD_CAMERA_SENSITIVITY * delta, -1.1, 0.2)
	camera_pivot.rotation.x = camera_pitch


func _is_near_interactable() -> bool:
	# Check if any Area3D interactable has player in range (door/shopman/police/box)
	var current_scene := get_tree().current_scene
	if current_scene == null:
		return false
	var areas: Array = current_scene.find_children("*", "Area3D", true, false)
	for area in areas:
		if "player_in_range" in area and area.get("player_in_range"):
			return true
		if "_player_in_range" in area and area.get("_player_in_range"):
			return true
	return false


func _find_animation_player() -> AnimationPlayer:
	return model.find_child("AnimationPlayer", true, false) as AnimationPlayer

func _update_animation() -> void:
	if not animation_player:
		return

	if not is_on_floor():
		animation_player.speed_scale = 1.0
		_play_animation("Jump")
		return

	var horizontal_speed := Vector2(velocity.x, velocity.z).length()
	if horizontal_speed > 0.2:
		animation_player.speed_scale = 1.0
		_play_animation("Run")
	else:
		animation_player.speed_scale = 1.0
		_play_animation("Idle")

func _play_animation(animation_name: String) -> void:
	if animation_state == animation_name or not animation_player.has_animation(animation_name):
		return
	animation_player.play(animation_name)
	animation_state = animation_name

func _set_loop(animation_name: String) -> void:
	if animation_player.has_animation(animation_name):
		animation_player.get_animation(animation_name).loop_mode = Animation.LOOP_LINEAR
