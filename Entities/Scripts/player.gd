extends CharacterBody2D

@onready var movement_component: MovementComponent = $MovementComponent

@export var stick_deadzone: float = 0.1
@export var stick_maxzone: float = 1.0

var base_speed: float

func _ready() -> void:
	base_speed = movement_component.max_speed


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
