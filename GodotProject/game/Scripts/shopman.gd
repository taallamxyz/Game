extends Area3D

@export_file("*.dtl") var dialogue_timeline := "res://Dialogues/shopman_intro.dtl"

var player_in_range := false
@onready var interaction_indicator: Label3D = $InteractionIndicator
@onready var animation_player: AnimationPlayer = find_child("AnimationPlayer", true, false) as AnimationPlayer

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	Dialogic.timeline_ended.connect(_on_dialogue_ended)
	interaction_indicator.visible = false
	_update_indicator_text()
	Input.joy_connection_changed.connect(_on_joy_connection_changed)
	if animation_player and animation_player.has_animation("Idle"):
		animation_player.get_animation("Idle").loop_mode = Animation.LOOP_LINEAR
		animation_player.play("Idle")


func _update_indicator_text() -> void:
	var use_joypad := Input.get_connected_joypads().size() > 0
	interaction_indicator.text = "✕" if use_joypad else "E"


func _on_joy_connection_changed(_device: int, _connected: bool) -> void:
	_update_indicator_text()

func _unhandled_input(event: InputEvent) -> void:
	if player_in_range and event.is_action_pressed("interact"):
		if Dialogic.current_timeline == null:
			Dialogic.start(dialogue_timeline)
			interaction_indicator.visible = false
			get_viewport().set_input_as_handled()

func _on_dialogue_ended() -> void:
	if player_in_range:
		interaction_indicator.visible = true

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		player_in_range = true
		_update_indicator_text()
		interaction_indicator.visible = true

func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		player_in_range = false
		interaction_indicator.visible = false
