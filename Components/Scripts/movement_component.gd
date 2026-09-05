class_name MovementComponent
extends Node2D

@export_group("Movement Stats")
@export var max_speed: float = 200.0
@export var acceleration: float = 1200.0
@export var friction: float = 1200.0

var move_direction: Vector2 = Vector2.ZERO
var body: CharacterBody2D

func _ready() -> void:
	body = get_parent() as CharacterBody2D
	assert(body != null, "MovementComponent must be a child of a CharacterBody2D")

func _physics_process(delta: float) -> void:
	if not body:
		return
	if move_direction != Vector2.ZERO:
		var target_velocity = move_direction.normalized() * max_speed
		body.velocity = body.velocity.move_toward(target_velocity, acceleration * delta)
	else:
		body.velocity = body.velocity.move_toward(Vector2.ZERO, friction * delta)
	
	body.move_and_slide()

func set_move_direction(dir: Vector2) -> void:
	move_direction = dir

func stop_instant() -> void:
	move_direction = Vector2.ZERO
	if body:
		body.velocity = Vector2.ZERO
