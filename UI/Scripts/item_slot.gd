class_name ItemSlotUI
extends PanelContainer

signal slot_pressed(slot_index: int, mouse_button: int)

@onready var icon_rect: TextureRect = $MarginContainer/Icon
@onready var quantity_label: Label = $MarginContainer/Quantity

var slot_index: int = -1
var slot_data: InventorySlotData


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
	if event is InputEventMouseButton and event.is_pressed():
		slot_pressed.emit(slot_index, event.button_index)
