class_name DamageReceiverComponent
extends Area2D

signal damage_received(damage_data: DamageData)
signal damage_blocked(reason: String)

@export_group("Dependencies")
@export var health_component: HealthComponent
@export var armor_component: ArmorComponent
@export var invulnerability_component: InvulnerabilityComponent

@export_group("Hit Invulnerability")
@export var post_hit_invulnerability: float = 0.3


func receive_damage(damage_data: DamageData) -> bool:
	if not health_component or health_component.is_dead():
		return false
		
	# 1. Check Invulnerability (if component exists and is active)
	if invulnerability_component and invulnerability_component.is_invulnerable():
		damage_blocked.emit("invulnerable")
		return false
	if health_component.is_invulnerable:
		damage_blocked.emit("invulnerable")
		return false

	# 2. Calculate Mitigated Damage (via ArmorComponent if present)
	var final_damage: float = damage_data.amount
	if armor_component:
		final_damage = armor_component.calculate_mitigated_damage(damage_data.amount)
	
	# 3. Apply damage to HealthComponent
	health_component.take_damage(final_damage)
	damage_received.emit(damage_data)
	
	# 4. Trigger post-hit i-frames
	if invulnerability_component and post_hit_invulnerability > 0.0:
		invulnerability_component.add_invulnerability("hit", post_hit_invulnerability)
		
	return true
