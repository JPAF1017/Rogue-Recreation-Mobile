class_name InventoryComponent
extends Node

signal inventory_updated
signal slot_updated(index: int, slot: InventorySlotData)
signal item_added(item: ItemData, amount: int)
signal item_removed(item: ItemData, amount: int)

@export_range(1, 100, 1) var capacity: int = 20
@export var starting_items: Array[ItemData] = []

var slots: Array[InventorySlotData] = []


func _ready() -> void:
	slots.resize(capacity)
	for i in range(capacity):
		slots[i] = InventorySlotData.new()

	for item in starting_items:
		if item:
			add_item(item, 1)


func add_item(item: ItemData, amount: int = 1) -> bool:
	if item == null or amount <= 0:
		return false

	var remaining: int = amount

	## 1. Try to stack in existing slots first
	if item.is_stackable:
		for i in range(capacity):
			if slots[i].can_stack_with(item):
				remaining = slots[i].add_quantity(remaining)
				slot_updated.emit(i, slots[i])
				if remaining <= 0:
					break

	## 2. Fill empty slots with the remainder
	if remaining > 0:
		for i in range(capacity):
			if slots[i].is_empty():
				var stack_limit: int = item.max_stack_size if item.is_stackable else 1
				var to_add: int = mini(remaining, stack_limit)
				slots[i] = InventorySlotData.new(item, to_add)
				remaining -= to_add
				slot_updated.emit(i, slots[i])
				if remaining <= 0:
					break

	var added_total: int = amount - remaining
	if added_total > 0:
		item_added.emit(item, added_total)
		inventory_updated.emit()
		return true

	return false


func remove_at_slot(index: int, amount: int = 1) -> bool:
	if index < 0 or index >= capacity or slots[index].is_empty():
		return false

	var slot: InventorySlotData = slots[index]
	var removed_item: ItemData = slot.item
	var removed_amount: int = mini(slot.quantity, amount)

	slot.quantity -= removed_amount
	if slot.quantity <= 0:
		slot.clear()

	slot_updated.emit(index, slot)
	item_removed.emit(removed_item, removed_amount)
	inventory_updated.emit()
	return true


func get_item_count(item_id: StringName) -> int:
	var total: int = 0
	for slot in slots:
		if not slot.is_empty() and slot.item.id == item_id:
			total += slot.quantity
	return total


func consume_item(item_id: StringName, amount: int = 1) -> bool:
	if get_item_count(item_id) < amount:
		return false

	var needed: int = amount
	for i in range(capacity):
		var slot: InventorySlotData = slots[i]
		if not slot.is_empty() and slot.item.id == item_id:
			var to_take: int = mini(slot.quantity, needed)
			slot.quantity -= to_take
			needed -= to_take
			if slot.quantity <= 0:
				slot.clear()
			slot_updated.emit(i, slot)
			if needed <= 0:
				break

	inventory_updated.emit()
	return true


func swap_slots(index_a: int, index_b: int) -> void:
	if index_a < 0 or index_a >= capacity or index_b < 0 or index_b >= capacity:
		return
	var temp := slots[index_a]
	slots[index_a] = slots[index_b]
	slots[index_b] = temp
	slot_updated.emit(index_a, slots[index_a])
	slot_updated.emit(index_b, slots[index_b])
	inventory_updated.emit()
