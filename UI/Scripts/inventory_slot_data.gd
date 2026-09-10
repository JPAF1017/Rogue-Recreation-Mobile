class_name InventorySlotData
extends RefCounted

var item: ItemData = null
var quantity: int = 0

func _init(p_item: ItemData = null, p_quantity: int = 0) -> void:
	item = p_item
	quantity = p_quantity if p_item != null else 0


func is_empty() -> bool:
	return item == null or quantity <= 0


func clear() -> void:
	item = null
	quantity = 0


func can_stack_with(other_item: ItemData) -> bool:
	if is_empty() or other_item == null:
		return false
	return item.id == other_item.id and item.is_stackable and quantity < item.max_stack_size


func add_quantity(amount: int) -> int:
	if not item or not item.is_stackable:
		return amount
	var space_left: int = item.max_stack_size - quantity
	var added: int = mini(space_left, amount)
	quantity += added
	return amount - added ## Returns remainder
