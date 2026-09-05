extends CanvasLayer

@onready var health_bar: ProgressBar = $MarginContainer/PanelContainer/MarginContainer/VBoxContainer/HealthRow/HealthBar
@onready var health_value: Label = $MarginContainer/PanelContainer/MarginContainer/VBoxContainer/HealthRow/HealthValue
@onready var coins_label: Label = $MarginContainer/PanelContainer/MarginContainer/VBoxContainer/CoinsLabel

func _ready() -> void:
	var player := get_tree().get_first_node_in_group("player")
	var gs := get_node_or_null("/root/GameState")
	if player:
		player.health_changed.connect(_on_health_changed)
		player.coins_changed.connect(_on_coins_changed)
		# Prefer GameState if it has newer values (continuation)
		if gs and gs.coins != player.coins:
			_on_health_changed(gs.health, gs.max_health)
			_on_coins_changed(gs.coins)
		else:
			_on_health_changed(player.health, player.max_health)
			_on_coins_changed(player.coins)
	elif gs:
		# No player yet (autoload HUD case), show stored state
		_on_health_changed(gs.health, gs.max_health)
		_on_coins_changed(gs.coins)

func _on_health_changed(current_health: int, maximum_health: int) -> void:
	health_bar.max_value = maximum_health
	health_bar.value = current_health
	health_value.text = "%d / %d" % [current_health, maximum_health]

func _on_coins_changed(amount: int) -> void:
	coins_label.text = "Coins: %d" % amount
