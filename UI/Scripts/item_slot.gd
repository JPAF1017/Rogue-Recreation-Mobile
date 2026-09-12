class_name ItemSlotUI
extends PanelContainer

signal slot_pressed(slot_index: int, mouse_button: int)
signal slot_dropped(from_index: int, to_index: int)

@onready var icon_rect: TextureRect = $MarginContainer/Icon
@onready var quantity_label: Label = $MarginContainer/Quantity

var slot_index: int = -1
var slot_data: InventorySlotData

var _is_pressed: bool = false
var _drag_started: bool = false


func setup(index: int) -> void:
	slot_index = index


func update_slot(p_slot_data: InventorySlotData) -> void:
	slot_data = p_slot_data

	if not slot_data or slot_data.is_empty():
		icon_rect.texture = null
		quantity_label.text = ""
		quantity_label.visible = false
		return

	icon_rect.texture = slot_data.item.icon
	if slot_data.item.is_stackable and slot_data.quantity > 1:
		quantity_label.text = str(slot_data.quantity)
		quantity_label.visible = true
	else:
		quantity_label.visible = false


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed():
			_is_pressed = true
			_drag_started = false
		else:
			if _is_pressed and not _drag_started:
				slot_pressed.emit(slot_index, event.button_index)
			_is_pressed = false
			_drag_started = false


func _notification(what: int) -> void:
	if what == NOTIFICATION_DRAG_END:
		_drag_started = false
		_is_pressed = false


func _get_drag_data(_at_position: Vector2) -> Variant:
	if not slot_data or slot_data.is_empty():
		return null

	_drag_started = true

	var preview_texture := TextureRect.new()
	preview_texture.texture = slot_data.item.icon
	preview_texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview_texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	preview_texture.custom_minimum_size = size
	preview_texture.modulate = Color(1.0, 1.0, 1.0, 0.8)

	var preview_holder := Control.new()
	preview_holder.add_child(preview_texture)
	preview_texture.position = -size * 0.5
	set_drag_preview(preview_holder)

	return {
		"origin_slot_index": slot_index,
		"item": slot_data.item
	}


func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return data is Dictionary and data.has("origin_slot_index")


func _drop_data(_at_position: Vector2, data: Variant) -> void:
	if _can_drop_data(_at_position, data):
		var from_index: int = data["origin_slot_index"]
		slot_dropped.emit(from_index, slot_index)
