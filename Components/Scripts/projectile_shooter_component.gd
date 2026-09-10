class_name ProjectileShooterComponent
extends Node2D

signal attack_started(direction: Vector2)
signal projectile_spawned(projectile: Node2D)
signal attack_cooldown_finished
signal projectile_type_changed(new_type: ProjectileType)

enum AimMode {
	ROTATOR_COMPONENT,
	TARGET_DETECTOR,
	INPUT_VECTOR,
	MARKER_ROTATION,
	MOUSE_OR_TOUCH
}

enum ProjectileType {
	STANDARD_BULLET,
	HIGH_SPEED_LASER,
	SHOTGUN_SPREAD,
	HEAVY_ROUND,
	CUSTOM
}

@export_group("Projectile Selection & Testing")
@export var active_projectile_type: ProjectileType = ProjectileType.STANDARD_BULLET:
	set(value):
		active_projectile_type = value
		_on_projectile_type_changed()

@export var standard_bullet_scene: PackedScene
@export var high_speed_laser_scene: PackedScene
@export var shotgun_spread_scene: PackedScene
@export var heavy_round_scene: PackedScene
@export var custom_projectile_scene: PackedScene

@export_group("Spawn & Aiming")
@export var spawn_marker: Marker2D
@export var spawn_distance: float = 0.0
@export var rotate_spawn_marker: bool = true
@export var aim_mode: AimMode = AimMode.ROTATOR_COMPONENT
@export var rotator_component: RotatorComponent
@export var target_detector: TargetDetectorComponent
@export var flipper_component: FlipperComponent

@export_group("Combat & Ballistics")
@export var damage: float = 20.0
@export var knockback_force: float = 150.0
@export var fire_rate: float = 0.25
@export var auto_fire: bool = false

@export_group("Long Range Motion & Lifetime")
@export var projectile_speed: float = 650.0
@export var max_travel_distance: float = 600.0
@export var max_lifetime: float = 2.5
@export var max_pierce_count: int = 1

@export_group("Multi-Shot & Accuracy")
@export_range(1, 16, 1) var projectiles_per_shot: int = 1 
@export_range(0.0, 90.0, 0.5) var spread_angle_degrees: float = 0.0
@export_range(0.0, 45.0, 0.5) var inaccuracy_degrees: float = 0.0
@export var recoil_force: float = 0.0

@export_group("Status Effects (Future Use)")
@export var status_effect_component: Node

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
var _is_firing_pressed: bool = false


func _ready() -> void:
	_owner_body = owner as Node2D
	if not _owner_body:
		_owner_body = get_parent() as Node2D

	if not spawn_marker:
		spawn_marker = get_node_or_null("SpawnMarker") as Marker2D

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
		_is_firing_pressed = true
		trigger_shot()
	elif event.is_action_released(attack_action):
		_is_firing_pressed = false


func _physics_process(delta: float) -> void:
	if _cooldown_timer > 0.0:
		_cooldown_timer -= delta
		if _cooldown_timer <= 0.0:
			attack_cooldown_finished.emit()

	if auto_fire and _is_firing_pressed and can_shoot():
		trigger_shot()

	_update_spawn_marker()


func can_shoot() -> bool:
	return _cooldown_timer <= 0.0


func trigger_shot(custom_direction: Vector2 = Vector2.ZERO) -> bool:
	if not can_shoot():
		return false

	var current_scene := get_active_projectile_scene()
	if not current_scene:
		push_warning("ProjectileShooterComponent: No PackedScene assigned for %s!" % [
			ProjectileType.keys()[active_projectile_type]
		])
		return false

	var base_direction := custom_direction
	if base_direction == Vector2.ZERO:
		base_direction = _calculate_aim_direction()

	_cooldown_timer = fire_rate
	attack_started.emit(base_direction)

	if projectiles_per_shot == 1:
		var final_dir := _apply_inaccuracy(base_direction)
		_spawn_single_projectile(current_scene, final_dir)
	else:
		var spread_rad := deg_to_rad(spread_angle_degrees)
		var angle_step := 0.0
		if projectiles_per_shot > 1:
			angle_step = spread_rad / float(projectiles_per_shot - 1)

		var start_angle := -spread_rad * 0.5

		for i in range(projectiles_per_shot):
			var angle_offset := start_angle + (i * angle_step)
			var bullet_dir := base_direction.rotated(angle_offset)
			bullet_dir = _apply_inaccuracy(bullet_dir)
			_spawn_single_projectile(current_scene, bullet_dir)

	if recoil_force > 0.0 and _owner_body is CharacterBody2D:
		var char_body := _owner_body as CharacterBody2D
		char_body.velocity -= base_direction * recoil_force

	return true


func _spawn_single_projectile(scene: PackedScene, direction: Vector2) -> void:
	var proj_instance := scene.instantiate() as Node2D
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
			max_lifetime,
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


func _apply_inaccuracy(dir: Vector2) -> Vector2:
	if inaccuracy_degrees <= 0.0:
		return dir
	var random_deg := randf_range(-inaccuracy_degrees, inaccuracy_degrees)
	return dir.rotated(deg_to_rad(random_deg)).normalized()


func get_active_projectile_scene() -> PackedScene:
	match active_projectile_type:
		ProjectileType.STANDARD_BULLET:
			return standard_bullet_scene
		ProjectileType.HIGH_SPEED_LASER:
			return high_speed_laser_scene
		ProjectileType.SHOTGUN_SPREAD:
			return shotgun_spread_scene
		ProjectileType.HEAVY_ROUND:
			return heavy_round_scene
		ProjectileType.CUSTOM:
			return custom_projectile_scene
	return null


func _on_projectile_type_changed() -> void:
	projectile_type_changed.emit(active_projectile_type)


func cycle_projectile_type() -> void:
	var total_types := ProjectileType.size()
	active_projectile_type = ((active_projectile_type + 1) % total_types) as ProjectileType


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
	if attack_button:
		if not attack_button.button_down.is_connected(_on_button_down):
			attack_button.button_down.connect(_on_button_down)
		if not attack_button.button_up.is_connected(_on_button_up):
			attack_button.button_up.connect(_on_button_up)


func _disconnect_attack_button() -> void:
	if attack_button:
		if attack_button.button_down.is_connected(_on_button_down):
			attack_button.button_down.disconnect(_on_button_down)
		if attack_button.button_up.is_connected(_on_button_up):
			attack_button.button_up.disconnect(_on_button_up)


func _on_button_down() -> void:
	_is_firing_pressed = true
	trigger_shot()


func _on_button_up() -> void:
	_is_firing_pressed = false


func assign_button(button: BaseButton) -> void:
	self.attack_button = button
