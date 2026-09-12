class_name InventoryGridUI
extends PanelContainer

@export var item_slot_scene: PackedScene = preload("res://UI/item_slot.tscn")
@export var inventory_component: InventoryComponent
@export var equipment_component: EquipmentComponent

@onready var slot_grid: GridContainer = $VBoxContainer/ScrollContainer/SlotGrid

var _slot_ui_nodes: Array[ItemSlotUI] = []


func _ready() -> void:
	if inventory_component:
		bind_inventory(inventory_component)


func bind_inventory(inventory: InventoryComponent) -> void:
	inventory_component = inventory
	inventory_component.inventory_updated.connect(_refresh_all)
	inventory_component.slot_updated.connect(_on_slot_updated)
	_build_grid()


func _build_grid() -> void:
	for child in slot_grid.get_children():
		child.queue_free()
	_slot_ui_nodes.clear()

	for i in range(inventory_component.capacity):
		var slot_ui: ItemSlotUI = item_slot_scene.instantiate() as ItemSlotUI
		slot_grid.add_child(slot_ui)
		slot_ui.setup(i)
		slot_ui.slot_pressed.connect(_on_slot_clicked)
		slot_ui.slot_dropped.connect(_on_slot_dropped) # <--- Connect drop event
		slot_ui.update_slot(inventory_component.slots[i])
		_slot_ui_nodes.append(slot_ui)


func _on_slot_updated(index: int, slot: InventorySlotData) -> void:
	if index >= 0 and index < _slot_ui_nodes.size():
		_slot_ui_nodes[index].update_slot(slot)


func _refresh_all() -> void:
	for i in range(inventory_component.slots.size()):
		if i < _slot_ui_nodes.size():
			_slot_ui_nodes[i].update_slot(inventory_component.slots[i])


func _on_slot_clicked(index: int, button_index: int) -> void:
	var slot := inventory_component.slots[index]
	if slot.is_empty():
		return

	if button_index == MOUSE_BUTTON_LEFT:
		if equipment_component and slot.item.item_type == ItemData.ItemType.EQUIPMENT:
			equipment_component.equip(slot.item)
			print("Equipped: %s" % slot.item.name)


func _on_slot_dropped(from_index: int, to_index: int) -> void:
	if inventory_component:
		inventory_component.move_slot(from_index, to_index)
