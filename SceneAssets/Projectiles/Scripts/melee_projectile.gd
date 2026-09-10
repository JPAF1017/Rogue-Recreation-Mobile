class_name MeleeProjectile
extends Area2D

signal enemy_hit(receiver: DamageReceiverComponent)
signal projectile_expired

enum LifetimeMode {
	TIMER_ONLY,
	ANIMATION_FINISHED,
	WHICHEVER_FIRST
}


@export_group("Lifetime & Mode")
@export var lifetime_mode: LifetimeMode = LifetimeMode.WHICHEVER_FIRST

@export_group("Visuals & Dissipation")
@export var visual_node: CanvasItem
@export var animation_name: StringName = &""
@export var fade_duration: float = 0.05

var _direction: Vector2 = Vector2.RIGHT
var _speed: float = 350.0
var _remaining_time: float = 0.2
var _max_distance: float = 0.0
var _distance_traveled: float = 0.0

var _damage: float = 25.0
var _knockback_force: float = 300.0
var _source_node: Node2D = null
var _status_effect_component: Node = null
var _max_pierce_count: int = -1

var _hit_receivers: Array[DamageReceiverComponent] = []
var _is_dying: bool = false


func _ready() -> void:
	area_entered.connect(_on_area_entered)
	if not visual_node:
		visual_node = self

	_setup_animation()


func _setup_animation() -> void:
	if visual_node is AnimatedSprite2D:
		var anim_sprite := visual_node as AnimatedSprite2D
		
		if not animation_name.is_empty():
			anim_sprite.play(animation_name)
		else:
			anim_sprite.play()

		if lifetime_mode == LifetimeMode.ANIMATION_FINISHED or lifetime_mode == LifetimeMode.WHICHEVER_FIRST:
			var anim_to_check := anim_sprite.animation
			if anim_sprite.sprite_frames and not anim_sprite.sprite_frames.get_animation_loop(anim_to_check):
				anim_sprite.animation_finished.connect(_on_animation_finished)


func setup_projectile(
	p_direction: Vector2,
	p_speed: float,
	p_duration: float,
	p_max_distance: float,
	p_damage: float,
	p_knockback: float,
	p_source: Node2D,
	p_status_effect: Node = null,
	p_pierce: int = -1
) -> void:
	_direction = p_direction.normalized()
	_speed = p_speed
	_remaining_time = p_duration
	_max_distance = p_max_distance
	_damage = p_damage
	_knockback_force = p_knockback
	_source_node = p_source
	_status_effect_component = p_status_effect
	_max_pierce_count = p_pierce


func _physics_process(delta: float) -> void:
	if _is_dying:
		return

	var movement: Vector2 = _direction * _speed * delta
	global_position += movement
	_distance_traveled += movement.length()

	if _max_distance > 0.0 and _distance_traveled >= _max_distance:
		_dissipate()
		return

	if lifetime_mode == LifetimeMode.TIMER_ONLY or lifetime_mode == LifetimeMode.WHICHEVER_FIRST:
		_remaining_time -= delta
		if _remaining_time <= 0.0:
			_dissipate()


func _on_animation_finished() -> void:
	if lifetime_mode == LifetimeMode.ANIMATION_FINISHED or lifetime_mode == LifetimeMode.WHICHEVER_FIRST:
		_dissipate()


func _on_area_entered(area: Area2D) -> void:
	if _is_dying:
		return

	if area is DamageReceiverComponent:
		var receiver := area as DamageReceiverComponent
		if receiver in _hit_receivers:
			return
		_hit_receivers.append(receiver)

		_apply_damage(receiver)
		_apply_status_effect(receiver)
		enemy_hit.emit(receiver)

		if _max_pierce_count > 0 and _hit_receivers.size() >= _max_pierce_count:
			_dissipate()


func _apply_damage(receiver: DamageReceiverComponent) -> void:
	var hit_dir: Vector2 = (receiver.global_position - global_position).normalized()
	if hit_dir == Vector2.ZERO:
		hit_dir = _direction

	var payload := DamageData.new(
		_damage,
		_source_node if is_instance_valid(_source_node) else self,
		_knockback_force,
		hit_dir
	)
	receiver.receive_damage(payload)


func _apply_status_effect(receiver: DamageReceiverComponent) -> void:
	if not is_instance_valid(_status_effect_component):
		return

	if _status_effect_component.has_method("apply_to_target"):
		_status_effect_component.apply_to_target(receiver.owner)
	elif _status_effect_component.has_method("apply_effect"):
		_status_effect_component.apply_effect(receiver.owner)


func _dissipate() -> void:
	if _is_dying:
		return
	_is_dying = true
	projectile_expired.emit()

	set_deferred("monitoring", false)
	set_deferred("monitorable", false)

	if fade_duration > 0.0 and is_instance_valid(visual_node):
		var tween := create_tween()
		tween.tween_property(visual_node, "modulate:a", 0.0, fade_duration)
		tween.tween_callback(queue_free)
	else:
		queue_free()
