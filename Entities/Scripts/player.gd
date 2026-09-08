extends CharacterBody2D

@onready var movement_component: MovementComponent = $MovementComponent
@onready var health_component: HealthComponent = $HealthComponent

@export var stick_deadzone: float = 0.1
@export var stick_maxzone: float = 1.0

var base_speed: float

func _ready() -> void:
	add_to_group("player")
	base_speed = movement_component.max_speed
	health_component.health_changed.connect(_on_health_changed)
	health_component.damaged.connect(_on_damaged)
	health_component.healed.connect(_on_healed)
	health_component.died.connect(_on_died)


func _process(delta: float) -> void:
	var raw_input := Input.get_vector("A", "D", "W", "S")
	
	if raw_input == Vector2.ZERO:
		movement_component.set_move_direction(Vector2.ZERO)
		return
		
	var stick_distance: float = raw_input.length()
	var speed_ratio: float = remap(stick_distance, stick_deadzone, stick_maxzone, 0.0, 1.0)
	
	speed_ratio = clampf(speed_ratio, 0.0, 1.0)
	
	movement_component.max_speed = base_speed * speed_ratio
	movement_component.set_move_direction(raw_input)


## Health related functions
func _on_health_changed(current: float, max_health: float) -> void:
	print("Player health: %s / %s" % [current, max_health])

func _on_damaged(amount: float) -> void:
	print("Player took %s damage!" % amount)

func _on_healed(amount: float) -> void:
	print("Player healed by %s!" % amount)

func _on_died() -> void:
	print("Player has died!")
	set_physics_process(false)
	$Collision.set_deferred("disabled", true)
	
	queue_free()
