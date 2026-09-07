@tool
class_name HealthBarComponent
extends TextureProgressBar

@export_group("Visual Overrides")
@export var custom_under_texture: Texture2D:
	set(value):
		custom_under_texture = value
		texture_under = value
@export var custom_progress_texture: Texture2D:
	set(value):
		custom_progress_texture = value
		texture_progress = value
@export var custom_over_texture: Texture2D:
	set(value):
		custom_over_texture = value
		texture_over = value
@export var progress_tint: Color = Color.WHITE:
	set(value):
		progress_tint = value
		tint_progress = value
@export_group("Dependencies")
@export var health_component: HealthComponent
@export var animate_transition: bool = true
@export var animation_speed: float = 0.2

var _tween: Tween


func setup(target_health_component: HealthComponent) -> void:
	if health_component and health_component.health_changed.is_connected(_on_health_changed):
		health_component.health_changed.disconnect(_on_health_changed)
	
	health_component = target_health_component
	if not health_component:
		return
	
	min_value = 0.0
	max_value = health_component.max_health
	value = health_component.current_health
	health_component.health_changed.connect(_on_health_changed)


func _on_health_changed(current: float, max_val: float) -> void:
	max_value = max_val
	
	if not animate_transition:
		value = current
		return
	
	if _tween and _tween.is_runing():
		_tween.kill()
	
	_tween = create_tween()
	_tween.tween_property(self, "value", current, animation_speed).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
