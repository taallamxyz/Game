extends Area3D

@export var open_animation := "Open"

var player_in_range := false
var is_open := false
@onready var animation_player: AnimationPlayer = find_child("AnimationPlayer", true, false) as AnimationPlayer
@onready var interaction_indicator: Label3D = $InteractionIndicator

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	interaction_indicator.visible = false

func _unhandled_input(event: InputEvent) -> void:
	if player_in_range and event.is_action_pressed("interact"):
		open()

func open() -> void:
	if is_open:
		return

	is_open = true
	interaction_indicator.visible = false
	if animation_player and animation_player.has_animation(open_animation):
		animation_player.play(open_animation)

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		player_in_range = true
		interaction_indicator.visible = not is_open

func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		player_in_range = false
		interaction_indicator.visible = false
