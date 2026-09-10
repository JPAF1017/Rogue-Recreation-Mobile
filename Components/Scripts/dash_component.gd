class_name DashComponent
extends Node2D

## Emitted when a dash begins.
signal dash_started(direction: Vector2)
## Emitted when the dash impulse finishes (including extensions).
signal dash_ended
## Emitted when the cooldown finishes and the dash is ready again.
signal cooldown_ended

@export_group("Dependencies")
@export var movement_component: MovementComponent
@export var invulnerability_component: InvulnerabilityComponent
@export var damage_receiver: DamageReceiverComponent

@export_group("Dash Settings")
@export var dash_speed: float = 900.0
@export var dash_duration: float = 0.15
@export var cooldown: float = 0.8
@export var grant_invulnerability: bool = true

@export_group("Player-Friendly Dash Extension")
## Automatically extend the dash if it ends on an enemy damage dealer area or in contact with an enemy
@export var enable_dash_extension: bool = true
## Extra clearance margin (in pixels) past the enemy required before ending the extended dash
@export var safety_clearance_margin: float = 16.0
## Maximum extra time (in seconds) the dash can extend to clear enemies
@export var max_extension_duration: float = 0.3
## Speed during extension. If <= 0, uses the default dash_speed
@export var extension_speed: float = -1.0

@export_group("Collision Settings")
## Physics layer index for enemies (1-indexed; Layer 3 is "enemy" in your project)
@export_range(1, 32) var enemy_collision_layer: int = 3

@export_group("Input & Controls")
## Project input action name (set empty to disable input action listening)
@export var dash_action: StringName = &"shift"
## Assign a UI Button directly from the Inspector
@export var dash_button: BaseButton:
	set(value):
		_disconnect_dash_button()
		dash_button = value
		_connect_dash_button()

var _body: CharacterBody2D
var _is_dashing: bool = false
var _is_extending_dash: bool = false
var _dash_timer: float = 0.0
var _cooldown_timer: float = 0.0
var _extension_timer: float = 0.0
var _dash_direction: Vector2 = Vector2.RIGHT
var _last_direction: Vector2 = Vector2.RIGHT
var _original_mask_enabled: bool = true


func _ready() -> void:
	_body = get_parent() as CharacterBody2D
	assert(_body != null, "DashComponent must be a child of a CharacterBody2D")

	# Auto-wire DamageReceiverComponent if not set in Inspector
	if not damage_receiver and _body:
		damage_receiver = _body.get_node_or_null("DamageReceiverComponent")

	_connect_dash_button()


func _unhandled_input(event: InputEvent) -> void:
	if not dash_action.is_empty() and event.is_action_pressed(dash_action):
		start_dash()


func _physics_process(delta: float) -> void:
	# Track movement direction to use as dash direction
	if movement_component and movement_component.move_direction != Vector2.ZERO:
		_last_direction = movement_component.move_direction.normalized()

	# Cooldown countdown
	if _cooldown_timer > 0.0:
		_cooldown_timer -= delta
		if _cooldown_timer <= 0.0:
			_cooldown_timer = 0.0
			cooldown_ended.emit()

	# 1. Standard active dash state
	if _is_dashing:
		_dash_timer -= delta
		_body.velocity = _dash_direction * dash_speed
		_body.move_and_slide()

		if _dash_timer <= 0.0:
			_is_dashing = false

			# Check if player is still touching an enemy or inside a damage dealer
			if enable_dash_extension and _is_in_danger_zone():
				_is_extending_dash = true
				_extension_timer = max_extension_duration
			else:
				_finish_dash()

	# 2. Player-friendly extension state: glide through until fully clear of danger
	elif _is_extending_dash:
		_extension_timer -= delta
		var speed: float = extension_speed if extension_speed > 0.0 else dash_speed
		_body.velocity = _dash_direction * speed
		_body.move_and_slide()

		# Exit extension once clear of danger zone or when maximum extension timeout is reached
		if not _is_in_danger_zone() or _extension_timer <= 0.0:
			_is_extending_dash = false
			_finish_dash()


## Starts the dash. Optional custom_direction can override input direction.
func start_dash(custom_direction: Vector2 = Vector2.ZERO) -> bool:
	if not can_dash():
		return false

	# Determine dash direction
	if custom_direction != Vector2.ZERO:
		_dash_direction = custom_direction.normalized()
	elif movement_component and movement_component.move_direction != Vector2.ZERO:
		_dash_direction = movement_component.move_direction.normalized()
	else:
		_dash_direction = _last_direction

	_is_dashing = true
	_is_extending_dash = false
	_dash_timer = dash_duration
	_cooldown_timer = cooldown

	# Disable collision mask on enemy layer so player can pass through
	if _body:
		_original_mask_enabled = _body.get_collision_mask_value(enemy_collision_layer)
		_body.set_collision_mask_value(enemy_collision_layer, false)

	# Pause normal movement component during dash
	if movement_component:
		movement_component.set_physics_process(false)

	# Apply invulnerability for the entire dash
	if grant_invulnerability and invulnerability_component:
		invulnerability_component.add_invulnerability("dash")

	dash_started.emit(_dash_direction)
	return true


func can_dash() -> bool:
	return not _is_dashing and not _is_extending_dash and _cooldown_timer <= 0.0


func get_cooldown_progress() -> float:
	if cooldown <= 0.0:
		return 1.0
	return clampf(1.0 - (_cooldown_timer / cooldown), 0.0, 1.0)


## Allows dynamically assigning a UI Button at runtime (e.g., from TouchControls)
func assign_button(button: BaseButton) -> void:
	self.dash_button = button


func _finish_dash() -> void:
	_is_dashing = false
	_is_extending_dash = false
	_dash_timer = 0.0

	# Safely restore collision mask on the enemy layer
	if _body and _original_mask_enabled:
		_body.set_collision_mask_value(enemy_collision_layer, true)

	# Remove dash invulnerability
	if grant_invulnerability and invulnerability_component:
		invulnerability_component.remove_invulnerability("dash")

	# Restore normal movement
	if movement_component:
		movement_component.set_physics_process(true)

	dash_ended.emit()


## Returns true if player is inside an enemy DamageDealer area OR touching an enemy collider
func _is_in_danger_zone() -> bool:
	return _is_in_damage_dealer_area() or _is_touching_enemy_body()


## Checks if player's DamageReceiverComponent is currently inside any enemy DamageDealer area
func _is_in_damage_dealer_area() -> bool:
	if damage_receiver and is_instance_valid(damage_receiver):
		for area in damage_receiver.get_overlapping_areas():
			if area is DamageDealerComponent:
				return true
			# Safety check if damage area belongs to an enemy node
			if area.owner and area.owner != _body and area.owner.is_in_group("enemy"):
				return true
	return false


## Checks if player's collision shape is touching or within safety_clearance_margin of an enemy
func _is_touching_enemy_body() -> bool:
	if not _body:
		return false

	var space_state := _body.get_world_2d().direct_space_state
	var query := PhysicsShapeQueryParameters2D.new()
	query.collision_mask = 1 << (enemy_collision_layer - 1)
	query.collide_with_bodies = true
	query.collide_with_areas = false
	query.margin = safety_clearance_margin

	for child in _body.get_children():
		if child is CollisionShape2D and not child.disabled and child.shape:
			query.shape = child.shape
			query.transform = child.global_transform
			var hits := space_state.intersect_shape(query, 1)
			if not hits.is_empty():
				return true

	return false


func _connect_dash_button() -> void:
	if dash_button and is_instance_valid(dash_button):
		if not dash_button.pressed.is_connected(_on_button_pressed):
			dash_button.pressed.connect(_on_button_pressed)


func _disconnect_dash_button() -> void:
	if dash_button and is_instance_valid(dash_button):
		if dash_button.pressed.is_connected(_on_button_pressed):
			dash_button.pressed.disconnect(_on_button_pressed)


func _on_button_pressed() -> void:
	start_dash()
