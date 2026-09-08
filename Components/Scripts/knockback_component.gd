class_name KnockbackComponent
extends Node2D

@export_group("Dependecies")
@export var damage_receiver: DamageReceiverComponent
@export var movement_component: MovementComponent

@export_group("Knockback Settings")
@export var decay_speed: float = 1800.0

var _body: CharacterBody2D
var _knockback_velocity: Vector2 = Vector2.ZERO


func _ready() -> void:
	_body = get_parent() as CharacterBody2D
	set_physics_process(false)

	if damage_receiver:
		damage_receiver.damage_received.connect(_on_damage_received)


func _physics_process(delta: float) -> void:
	if not _body:
		return
	
	_knockback_velocity = _knockback_velocity.move_toward(Vector2.ZERO, decay_speed * delta)
	_body.velocity = _knockback_velocity
	_body.move_and_slide()

	if _knockback_velocity == Vector2.ZERO:
		set_physics_process(false)
		if movement_component:
			movement_component.set_physics_process(true)


func _on_damage_received(data: DamageData) -> void:
	if data.knockback_force > 0.0 and data.knockback_direction != Vector2.ZERO:
		_knockback_velocity = data.knockback_direction * data.knockback_force
		if movement_component:
			movement_component.set_physics_process(false)
		set_physics_process(true)
