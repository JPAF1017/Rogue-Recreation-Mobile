class_name ArmorComponent
extends Node

signal armor_broken
signal armor_rusted(current_armor: float)

@export var base_armor: float = 0.0
var bonus_armor: float = 0.0


func get_total_armor() -> float:
	return maxf(0.0, base_armor + bonus_armor)


func calculate_mitigated_damage(incoming_damage: float, damage_type: String = "physical") -> float:
	if damage_type in ["poison", "fire", "magic", "starvation"]:
		return incoming_damage
	
	return maxf(1.0, incoming_damage - get_total_armor())


func rust_armor(amount: float = 1.0) -> void:
	base_armor = maxf(0.0, base_armor - amount)
	armor_rusted.emit(base_armor)