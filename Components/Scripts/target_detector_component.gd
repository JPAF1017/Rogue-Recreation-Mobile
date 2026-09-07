class_name TargetDetectorComponent
extends Area2D

signal target_changed(new_target: Node2D)

var current_target: Node2D = null
var _targets_in_range: Array[Node2D] = []


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	for body in get_overlapping_bodies():
		if body is Node2D:
			_on_body_entered(body)


func _process(_delta: float) -> void:
	_update_closest_target()


func _on_body_entered(body: Node2D) -> void:
	if body == self or body == get_parent() or body == owner:
		return
	if not _targets_in_range.has(body):
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
	
	var target_lost_validity := not is_instance_valid(current_target) and current_target != null
	if closest != current_target or target_lost_validity:
		current_target = closest
		target_changed.emit(current_target)


func get_target() -> Node2D:
	return current_target
