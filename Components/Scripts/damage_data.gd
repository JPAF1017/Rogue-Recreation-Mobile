class_name DamageData
extends RefCounted

var amount: float = 10.0
var source: Node2D = null
var knockback_force: float = 0.0
var knockback_direction: Vector2 = Vector2.ZERO


func _init(p_amount: float = 10.0, p_source: Node2D = null, p_knockback: float = 0.0, p_direction: Vector2 = Vector2.ZERO) -> void:
	amount = p_amount
	source = p_source
	knockback_force = p_knockback
	knockback_direction = p_direction
