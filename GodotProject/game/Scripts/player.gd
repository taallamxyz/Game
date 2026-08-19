extends CharacterBody3D

@export var WALK_SPEED := 2.5
@export var RUN_SPEED := 5.0
@export var JUMP_SPEED := 4.5
@export var ACCELERATION := 12.0
@export var ROTATION_SPEED := 10.0

@onready var model: Node3D = $Model
@onready var camera_pivot: Node3D = $CameraPivot
@onready var camera: Camera3D = $CameraPivot/Camera3D
@onready var animation_player: AnimationPlayer = _find_animation_player()

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var animation_state := ""
var camera_pitch := -0.55

func _ready() -> void:

	camera.position = Vector3(0.0, 2.2, 5.0)
	camera_pivot.rotation.x = camera_pitch
	camera.current = true

	if animation_player:
		_set_loop("Idle")
		_set_loop("Run")
		_play_animation("Idle")

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		camera_pivot.rotation.y -= event.relative.x * 0.003
		camera_pitch = clampf(camera_pitch - event.relative.y * 0.003, -1.1, 0.2)
		camera_pivot.rotation.x = camera_pitch
	elif event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	elif event is InputEventMouseButton and event.pressed:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
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
	_update_animation()

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
		animation_player.speed_scale = clampf(horizontal_speed / RUN_SPEED, 0.5, 1.25)
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
