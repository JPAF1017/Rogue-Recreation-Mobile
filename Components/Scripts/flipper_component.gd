class_name FlipperComponent
extends Node

@export var visual_to_flip: Node2D
@export var target_detector: TargetDetectorComponent
@export var fallback_to_velocity: bool = true

var _active_target: Node2D = null


func _ready() -> void:
	if target_detector:
		target_detector.target_changed.connect(func(t: Node2D) -> void: _active_target = t)


func _process(_delta: float) -> void:
	if not is_instance_valid(visual_to_flip):
		return
	
	if is_instance_valid(_active_target):
		var diff := _active_target.global_position.x - visual_to_flip.global_position.x
		if abs(diff) > 1.0:
			_set_facing(diff > 0.0)
	elif fallback_to_velocity:
		var parent_body := get_parent() as CharacterBody2D
		if parent_body and abs(parent_body.velocity.x) > 1.0:
			_set_facing(parent_body.velocity.x > 0.0)


func _set_facing(face_right: bool) -> void:
	visual_to_flip.scale.x = abs(visual_to_flip.scale.x) * (1.0 if face_right else -1.0)
