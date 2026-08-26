extends Area3D

@export_multiline var dialogue_text := "Officer: Stay safe while exploring the city.\nOfficer: Always look both ways before crossing the street."

var player_in_range := false
@onready var interaction_indicator: Label3D = $InteractionIndicator
@onready var animation_player: AnimationPlayer = find_child("AnimationPlayer", true, false) as AnimationPlayer

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	interaction_indicator.visible = false
	if animation_player and animation_player.has_animation("Idle"):
		animation_player.get_animation("Idle").loop_mode = Animation.LOOP_LINEAR
		animation_player.play("Idle")

func _unhandled_input(event: InputEvent) -> void:
	if player_in_range and event.is_action_pressed("interact"):
		var hud = get_tree().get_first_node_in_group("hud")
		if hud and hud.has_method("start_dialogue"):
			hud.start_dialogue(dialogue_text.split("\n"))
			get_viewport().set_input_as_handled()

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		player_in_range = true
		interaction_indicator.visible = true

func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		player_in_range = false
		interaction_indicator.visible = false
