extends CanvasLayer

@onready var health_bar: ProgressBar = $MarginContainer/PanelContainer/MarginContainer/VBoxContainer/HealthRow/HealthBar
@onready var health_value: Label = $MarginContainer/PanelContainer/MarginContainer/VBoxContainer/HealthRow/HealthValue
@onready var coins_label: Label = $MarginContainer/PanelContainer/MarginContainer/VBoxContainer/CoinsLabel

func _ready() -> void:
	var player := get_tree().get_first_node_in_group("player")
	if player:
		player.health_changed.connect(_on_health_changed)
		player.coins_changed.connect(_on_coins_changed)
		_on_health_changed(player.health, player.max_health)
		_on_coins_changed(player.coins)

func _on_health_changed(current_health: int, maximum_health: int) -> void:
	health_bar.max_value = maximum_health
	health_bar.value = current_health
	health_value.text = "%d / %d" % [current_health, maximum_health]

func _on_coins_changed(amount: int) -> void:
	coins_label.text = "Coins: %d" % amount
