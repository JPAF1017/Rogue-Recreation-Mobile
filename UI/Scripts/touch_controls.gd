extends Control

@onready var health_bar: HealthBarComponent = $CanvasLayer/PlayerHealthBar


func _ready() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player and player.health_component:
		health_bar.setup(player.health_component)
