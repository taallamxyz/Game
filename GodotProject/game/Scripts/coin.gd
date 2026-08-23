extends Area3D

@export var value := 1
@export var spin_speed := 2.5

@onready var model: Node3D = $Model

func _process(delta: float) -> void:
	model.rotate_y(spin_speed * delta)

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		body.add_coin(value)
		queue_free()
