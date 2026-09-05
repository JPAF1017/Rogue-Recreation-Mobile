class_name HealthComponent
extends Node2D

signal health_changed(current_health: float, max_health: float)
signal damaged(amount: float)
signal healed(amount: float)
signal died

@export_group("Health Settings")
@export var max_health: float = 100.0:
	set(value):
		max_health = max(1.0, value)
		if current_health > max_health:
			current_health = max_health
@export var is_invulnerable: bool = false

var current_health: float


func _ready() -> void:
	current_health = max_health
	health_changed.emit(current_health, max_health)


func take_damage(amount: float) -> void:
	if amount <= 0.0 or is_invulnerable or is_dead():
		return
	
	current_health = max(0.0, current_health - amount)
	damaged.emit(amount)
	health_changed.emit(current_health, max_health)
	
	if is_dead():
		died.emit()


func heal(amount: float) -> void:
	if amount <= 0.0 or is_dead():
		return
	
	var old_health := current_health
	current_health = min(max_health, current_health + amount)
	var effective_heal := current_health - old_health
	
	if effective_heal > 0.0:
		healed.emit(effective_heal)
		health_changed.emit(current_health, max_health)


func is_dead() -> bool:
	return current_health <= 0.0


func get_health_percent() -> float:
	return current_health / max_health
