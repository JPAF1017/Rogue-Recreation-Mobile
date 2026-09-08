class_name DamageDealerComponent
extends Area2D

@export_group("Damage Settings")
@export var damage: float = 15.0
@export var knockback_force: float = 250.0
@export var damage_interval: float = 0.5

var _target_timers: Dictionary = {}


func _ready() -> void:
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)


func _physics_process(delta: float) -> void:
	if damage_interval <= 0.0 or _target_timers.is_empty():
		return
	
	for receiver: DamageReceiverComponent in _target_timers.keys():
		if not is_instance_valid(receiver):
			_target_timers.erase(receiver)
			continue
		
		_target_timers[receiver] -= delta
		if _target_timers[receiver] <= 0.0:
			_hit_receiver(receiver)
			_target_timers[receiver] = damage_interval


func _on_area_entered(area: Area2D) -> void:
	if area is DamageReceiverComponent:
		_hit_receiver(area)
		if damage_interval > 0.0:
			_target_timers[area] = damage_interval


func _on_area_exited(area: Area2D) -> void:
	if area is DamageReceiverComponent:
		_target_timers.erase(area)


func _hit_receiver(receiver: DamageReceiverComponent) -> void:
	var knockback_dir: Vector2 = (receiver.global_position - global_position).normalized()
	var payload := DamageData.new(damage, owner as Node2D, knockback_force, knockback_dir)
	receiver.receive_damage(payload)
