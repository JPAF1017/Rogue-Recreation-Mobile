class_name FlashComponent
extends Node

enum FlashMode {
	MODULATE_TINT,
	SHADER_FLASH,
	ANIMATION_ONLY,
	HYBRID
}

@export_group("Target Visual")
@export var target_visual: CanvasItem

@export_group("Flash Settings")
@export var default_mode: FlashMode = FlashMode.MODULATE_TINT
@export var default_flash_color: Color = Color.WHITE
@export var default_duration: float = 0.12

# If using SHADER_FLASH
@export var shader_parameter_name: StringName = "flash_modifier"
@export var shader_color_parameter: StringName = "flash_color"

@export_group("Animation Overlay")
@export var animation_player: AnimationPlayer
@export var default_animation: StringName = &"hit_flash"

@export_group("Auto Triggers")
@export var damage_receiver: DamageReceiverComponent
@export var health_component: HealthComponent

var _active_tween: Tween
var _original_modulate: Color = Color.WHITE


func _ready() -> void:
	if not target_visual:
		if get_parent() is CanvasItem:
			target_visual = get_parent() as CanvasItem
	
	if target_visual:
		_original_modulate = target_visual.self_modulate
	
	_setup_auto_triggers()


func _setup_auto_triggers() -> void:
	if damage_receiver:
		damage_receiver.damage_received.connect(_on_damage_received)
	elif health_component:
		health_component.damaged.connect(_on_health_damaged)


func _on_damage_received(_damage_data: DamageData) -> void:
	flash_hit()


func _on_health_damaged(_amount: float) -> void:
	flash_hit()

# =======================================
# Public API
# =======================================
func flash_hit(duration: float = -1.0) -> void:
	var flash_time := default_duration if duration <= 0.0 else duration
	flash(default_flash_color, flash_time, default_mode, default_animation)


func flash_tint(color: Color, duration: float = 0.15) -> void:
	flash(color, duration, FlashMode.MODULATE_TINT)


func play_overlay(anim_name: StringName) -> void:
	if animation_player and animation_player.has_aniamtion(anim_name):
		animation_player.stop()
		animation_player.play(anim_name)


func flash(
	color: Color = default_flash_color,
	duration: float = default_duration,
	mode: FlashMode = default_mode,
	anim_name: StringName = default_animation
) -> void:
	if mode == FlashMode.ANIMATION_ONLY or mode == FlashMode.HYBRID:
		play_overlay(anim_name)
		if mode == FlashMode.ANIMATION_ONLY:
			return
	
	if not target_visual:
		return
	
	if _active_tween and _active_tween.is_valid():
		_active_tween.kill()
	
	match mode:
		FlashMode.MODULATE_TINT:
			_apply_modulate_flash(color, duration)
		FlashMode.SHADER_FLASH:
			_apply_shader_flash(color, duration)
		FlashMode.HYBRID:
			_apply_modulate_flash(color, duration)


# =======================================
# Internal Flash Drivers
# =======================================
func _apply_modulate_flash(color: Color, duration: float) -> void:
	target_visual.self_modulate = color
	_active_tween = create_tween()
	_active_tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_active_tween.tween_property(target_visual, "self_modulate", _original_modulate, duration)


func _apply_shader_flash(color: Color, duration: float) -> void:
	var mat := target_visual.material as ShaderMaterial
	if not mat:
		_apply_modulate_flash(color, duration)
		return
	
	mat.set_shader_parameter(shader_color_parameter, color)
	mat.set_shader_parameter(shader_parameter_name, 1.0)

	_active_tween = create_tween()
	_active_tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_active_tween.tween_method(
		func(val: float): mat.set_shader_parameter(shader_parameter_name, val),
		1.0,
		0.0,
		duration
	)
