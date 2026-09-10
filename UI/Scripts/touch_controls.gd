extends Control

@onready var health_bar: HealthBarComponent = $CanvasLayer/PlayerHealthBar
@onready var dash_button: Button = $DashButton
@onready var attack_button: Button = $AttackButton

func _ready() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return

	if player.health_component:
		health_bar.setup(player.health_component)

	var dash_component: DashComponent = player.get_node_or_null("DashComponent")
	if dash_component:
		dash_component.assign_button(dash_button)
	
	var melee_attack: MeleeAttackComponent = player.get_node_or_null("MeleeAttackComponent")
	if melee_attack:
		melee_attack.assign_button(attack_button)
