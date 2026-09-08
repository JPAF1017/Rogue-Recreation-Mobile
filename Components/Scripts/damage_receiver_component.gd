class_name DamageReceiverComponent
extends Area2D

signal damage_received(damage_data: DamageData)
signal damage_blocked(reason: String)

@export_group("Dependencies")
@export var health_component: HealthComponent

@export_group("Damage Settings")
@export var armor: float = 0.0
@export var invulnerability_duration: float = 0.3

var is_invulnerable: bool = false
var _invulnerability_timer: SceneTreeTimer = null


func receive_damage(damage_data: DamageData) -> bool:
	if not health_component or health_component.is_dead():
		return false
		
	if is_invulnerable or health_component.is_invulnerable:
		damage_blocked.emit("invulnerable")
		return false

	# Calculate reduced damage
	var effective_damage: float = max(1.0, damage_data.amount - armor)
	
	# Apply damage to HealthComponent
	health_component.take_damage(effective_damage)
	damage_received.emit(damage_data)
	
	# Start i-frame cooldown
	if invulnerability_duration > 0.0:
		_start_invulnerability()
		
	return true


func _start_invulnerability() -> void:
	is_invulnerable = true
	_invulnerability_timer = get_tree().create_timer(invulnerability_duration)
	_invulnerability_timer.timeout.connect(func(): is_invulnerable = false)
