class_name RotatorComponent
extends Node

@export var visual_to_rotate: Node2D
@export var target_detector: TargetDetectorComponent
@export var rotation_speed: float = 9.0
@export var fallback_to_velocity: bool = true

var _active_target: Node2D = null

func _ready() -> void:
	if target_detector:
		target_detector.target_changed.connect(_on_target_changed)
		_active_target = target_detector.get_target()
		print("[Rotator] Connected. Initial target: ", _active_target)
	else:
		push_error("[Rotator] target_detector is NULL! Check the Inspector.")


func _on_target_changed(new_target: Node2D) -> void:
	_active_target = new_target
	print("[Rotator] Signal received! New target: ", new_target)


func _process(delta: float) -> void:
	if not is_instance_valid(visual_to_rotate):
		return
	
	var target_angle: float
	
	if is_instance_valid(_active_target):
		target_angle = visual_to_rotate.global_position.angle_to_point(_active_target.global_position)
	elif fallback_to_velocity:
		var parent_body := get_parent() as CharacterBody2D
		if parent_body and parent_body.velocity.length_squared() > 1.0:
			target_angle = parent_body.velocity.angle()
		else:
			return
	else:
		return
	
	if rotation_speed <= 0.0:
		visual_to_rotate.global_rotation = target_angle
	else:
		visual_to_rotate.global_rotation = lerp_angle(
			visual_to_rotate.global_rotation,
			target_angle,
			rotation_speed * delta
		)
