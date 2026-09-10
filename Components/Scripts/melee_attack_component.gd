class_name MeleeAttackComponent
extends Node2D

signal attack_started(direction: Vector2)
signal attack_cooldown_finished
signal projectile_spawned(projectile: Node2D)

enum AimMode {
	TARGET_DETECTOR,
	INPUT_VECTOR,
	MARKER_ROTATION,
	MOUSE_OR_TOUCH,
	ROTATOR_COMPONENT
}

@export_group("Projectile Configuration")
@export var projectile_scene: PackedScene
@export var spawn_marker: Marker2D
@export var spawn_distance: float = 0.0

@export_group("Combat & Damage")
@export var damage: float = 25.0
@export var knockback_force: float = 300.0
@export var attack_cooldown: float = 0.35

@export_group("Motion & Lifetime")
@export var projectile_speed: float = 350.0
@export var travel_duration: float = 0.18
@export var max_travel_distance: float = 70.0
@export var max_pierce_count: int = -1

@export_group("Status Effects (Future Use)")
@export var status_effect_component: Node

@export_group("Aiming & Target Detection")
@export var aim_mode: AimMode = AimMode.ROTATOR_COMPONENT
@export var rotator_component: RotatorComponent
@export var rotate_spawn_marker: bool = true
@export var target_detector: TargetDetectorComponent
@export var flipper_component: FlipperComponent

@export_group("Input & Controls")
@export var attack_action: StringName = &"attack"
@export var attack_button: BaseButton:
	set(value):
		_disconnect_attack_button()
		attack_button = value
		_connect_attack_button()

var _cooldown_timer: float = 0.0
var _owner_body: Node2D
var _marker_distance: float = 40.0


func _ready() -> void:
	_owner_body = owner as Node2D
	if not _owner_body:
		_owner_body = get_parent() as Node2D
	
	if not spawn_marker:
		spawn_marker = get_node_or_null("SpawnMarker") as Marker2D
	
	if spawn_distance > 0.0:
		_marker_distance = spawn_distance

	if spawn_distance > 0.0:
		_marker_distance = spawn_distance
	elif is_instance_valid(spawn_marker):
		_marker_distance = spawn_marker.position.length()
		if _marker_distance <= 0.0:
			_marker_distance = 40.0


func _unhandled_input(event: InputEvent) -> void:
	if attack_action.is_empty():
		return
	if event.is_action_pressed(attack_action):
		trigger_attack()


func _physics_process(delta: float) -> void:
	if _cooldown_timer > 0.0:
		_cooldown_timer -= delta
		if _cooldown_timer <= 0.0:
			attack_cooldown_finished.emit()

	_update_spawn_marker()


func can_attack() -> bool:
	return _cooldown_timer <= 0.0


func trigger_attack(custom_direction: Vector2 = Vector2.ZERO) -> bool:
	if not can_attack():
		return false
	
	if not projectile_scene:
		push_warning("MeleeAttackComponent: No projectile_scene assigned!")
		return false
	
	var attack_dir: Vector2 = custom_direction
	if attack_dir == Vector2.ZERO:
		attack_dir = _calculate_aim_direction()
	
	_cooldown_timer = attack_cooldown
	attack_started.emit(attack_dir)

	_spawn_projectile(attack_dir)
	return true


func _spawn_projectile(direction: Vector2) -> void:
	var proj_instance := projectile_scene.instantiate() as Node2D
	if not proj_instance:
		return
	
	var spawn_pos: Vector2 = global_position
	if is_instance_valid(spawn_marker):
		spawn_pos = spawn_marker.global_position
	
	proj_instance.global_position = spawn_pos
	proj_instance.global_rotation = direction.angle()

	if proj_instance.has_method("setup_projectile"):
		proj_instance.setup_projectile(
			direction,
			projectile_speed,
			travel_duration,
			max_travel_distance,
			damage,
			knockback_force,
			_owner_body,
			status_effect_component,
			max_pierce_count
		)

	var spawn_root: Node = get_tree().current_scene
	if not spawn_root:
		spawn_root = get_parent()
	
	spawn_root.add_child(proj_instance)
	projectile_spawned.emit(proj_instance)


func _update_spawn_marker() -> void:
	if not rotate_spawn_marker or not is_instance_valid(spawn_marker):
		return

	if not is_instance_valid(rotator_component) or not rotator_component.visual_to_rotate:
		return
	
	if spawn_marker.get_parent() == rotator_component.visual_to_rotate:
		return

	var angle := rotator_component.visual_to_rotate.global_rotation
	spawn_marker.position = Vector2.RIGHT.rotated(angle) * _marker_distance
	spawn_marker.global_rotation = angle


func _calculate_aim_direction() -> Vector2:
	match aim_mode:
		AimMode.ROTATOR_COMPONENT:
			if is_instance_valid(rotator_component) and rotator_component.visual_to_rotate:
				return Vector2.RIGHT.rotated(rotator_component.visual_to_rotate.global_rotation)
		AimMode.TARGET_DETECTOR:
			if is_instance_valid(target_detector):
				var target: Node2D = target_detector.get_target()
				if is_instance_valid(target):
					return (target.global_position - global_position).normalized()
		
		AimMode.INPUT_VECTOR:
			var input_dir := Input.get_vector("A", "D", "W", "S")
			if input_dir.length_squared() > 0.01:
				return input_dir.normalized()
		
		AimMode.MARKER_ROTATION:
			if is_instance_valid(spawn_marker):
				return Vector2.RIGHT.rotated(spawn_marker.global_rotation)
		
		AimMode.MOUSE_OR_TOUCH:
			var mouse_pos := get_global_mouse_position()
			var diff := mouse_pos - global_position
			if diff.length_squared() > 0.01:
				return diff.normalized()
	
	var parent_body := _owner_body as CharacterBody2D

	if parent_body and parent_body.velocity.length_squared() > 1.0:
		return parent_body.velocity.normalized()
	
	if is_instance_valid(flipper_component) and flipper_component.visual_to_flip:
		return Vector2.RIGHT if flipper_component.visual_to_flip.scale.x > 0 else Vector2.LEFT

	return Vector2.RIGHT



func _connect_attack_button() -> void:
	if attack_button and not attack_button.pressed.is_connected(trigger_attack):
		attack_button.pressed.connect(trigger_attack)


func _disconnect_attack_button() -> void:
	if attack_button and attack_button.pressed.is_connected(trigger_attack):
		attack_button.pressed.disconnect(trigger_attack)
