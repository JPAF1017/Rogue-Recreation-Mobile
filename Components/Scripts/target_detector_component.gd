class_name TargetDetectorComponent
extends Area2D

signal target_changed(new_target: Node2D)

@export var visual_to_rotate: Node2D
@export var rotation_speed: float = 9.0
@export var toggle_rotation: bool = true

var current_target: Node2D = null
var _targets_in_range: Array[Node2D] = []

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _process(delta: float) -> void:
	_update_closest_target()
	_rotate_visual(delta)


func _on_body_entered(body: Node2D) -> void:
	if body != get_parent() and not _targets_in_range.has(body):
		_targets_in_range.append(body)


func _on_body_exited(body: Node2D) -> void:
	_targets_in_range.erase(body)


func _update_closest_target() -> void:
	var closest: Node2D = null
	var shortest_dist_sq: float = INF
	
	var i := _targets_in_range.size() - 1
	while i >= 0:
		var target := _targets_in_range[i]
		if not is_instance_valid(target):
			_targets_in_range.remove_at(i)
		else:
			var dist_sq := global_position.distance_squared_to(target.global_position)
			if dist_sq < shortest_dist_sq:
				shortest_dist_sq = dist_sq
				closest = target
		i -= 1
		
	if closest != current_target:
		current_target = closest
		target_changed.emit(current_target)


func _rotate_visual(delta: float) -> void:
	if not toggle_rotation or not is_instance_valid(visual_to_rotate):
		return
	
	var target_angle: float
	
	if is_instance_valid(current_target):
		target_angle = visual_to_rotate.global_position.angle_to_point(current_target.global_position)
	else:
		var parent_body := get_parent() as CharacterBody2D
		if parent_body and parent_body.velocity.length_squared() > 1.0:
			target_angle = parent_body.velocity.angle()
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


func get_target() -> Node2D:
	return current_target
