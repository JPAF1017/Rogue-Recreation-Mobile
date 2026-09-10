class_name EquipmentComponent
extends Node

signal equipment_changed(slot: ItemData.EquipmentSlotType, item: ItemData)
signal ammo_depleted(ammo_id: StringName)

@export_group("Dependencies")
@export var inventory: InventoryComponent
@export var melee_attack_component: MeleeAttackComponent
@export var projectile_shooter_component: ProjectileShooterComponent

@export_group("Equipped Slots")
@export var main_hand_item: ItemData = null
@export var ammo_item: ItemData = null
@export var armor_item: ItemData = null

var _equipped_items: Dictionary = {}


func _ready() -> void:
	if main_hand_item:
		equip(main_hand_item)
	if ammo_item:
		equip(ammo_item)
	_apply_equipment_state()


func equip(item: ItemData) -> bool:
	if item == null or item.equipment_slot == ItemData.EquipmentSlotType.NONE:
		return false

	var slot := item.equipment_slot
	var previous_item: ItemData = _equipped_items.get(slot, null)

	_equipped_items[slot] = item

	## Sync exported properties for inspector debugging
	match slot:
		ItemData.EquipmentSlotType.MAIN_HAND: main_hand_item = item
		ItemData.EquipmentSlotType.AMMO: ammo_item = item
		ItemData.EquipmentSlotType.ARMOR: armor_item = item

	_apply_equipment_state()
	equipment_changed.emit(slot, item)
	return true


func unequip(slot: ItemData.EquipmentSlotType) -> ItemData:
	if not _equipped_items.has(slot):
		return null

	var item: ItemData = _equipped_items[slot]
	_equipped_items.erase(slot)

	match slot:
		ItemData.EquipmentSlotType.MAIN_HAND: main_hand_item = null
		ItemData.EquipmentSlotType.AMMO: ammo_item = null
		ItemData.EquipmentSlotType.ARMOR: armor_item = null

	_apply_equipment_state()
	equipment_changed.emit(slot, null)
	return item


func get_equipped_item(slot: ItemData.EquipmentSlotType) -> ItemData:
	return _equipped_items.get(slot, null)


## Intercepts attack trigger or verifies ammo before firing
func can_attack() -> bool:
	var weapon: ItemData = get_equipped_item(ItemData.EquipmentSlotType.MAIN_HAND)
	if not weapon:
		return false

	if weapon.weapon_type == ItemData.WeaponType.RANGED:
		if weapon.required_ammo_id != &"":
			var ammo_count: int = get_available_ammo(weapon.required_ammo_id)
			return ammo_count > 0

	return true


func consume_required_ammo() -> bool:
	var weapon: ItemData = get_equipped_item(ItemData.EquipmentSlotType.MAIN_HAND)
	if not weapon or weapon.weapon_type != ItemData.WeaponType.RANGED or weapon.required_ammo_id == &"":
		return true

	var ammo_id: StringName = weapon.required_ammo_id
	if inventory and inventory.consume_item(ammo_id, 1):
		if inventory.get_item_count(ammo_id) <= 0:
			ammo_depleted.emit(ammo_id)
		return true
	return false


func get_available_ammo(ammo_id: StringName) -> int:
	return inventory.get_item_count(ammo_id) if inventory else 0


## Configures Melee and Projectile components according to active gear
func _apply_equipment_state() -> void:
	var weapon: ItemData = get_equipped_item(ItemData.EquipmentSlotType.MAIN_HAND)

	if weapon == null:
		if melee_attack_component: melee_attack_component.process_mode = Node.PROCESS_MODE_DISABLED
		if projectile_shooter_component: projectile_shooter_component.process_mode = Node.PROCESS_MODE_DISABLED
		return

	match weapon.weapon_type:
		ItemData.WeaponType.MELEE:
			if melee_attack_component:
				melee_attack_component.process_mode = Node.PROCESS_MODE_INHERIT
				melee_attack_component.damage = weapon.damage
				melee_attack_component.attack_cooldown = weapon.attack_cooldown
				melee_attack_component.knockback_force = weapon.knockback_force
				if weapon.attack_scene:
					melee_attack_component.projectile_scene = weapon.attack_scene

			if projectile_shooter_component:
				projectile_shooter_component.process_mode = Node.PROCESS_MODE_DISABLED

		ItemData.WeaponType.RANGED:
			if projectile_shooter_component:
				projectile_shooter_component.process_mode = Node.PROCESS_MODE_INHERIT
				projectile_shooter_component.damage = weapon.damage
				projectile_shooter_component.fire_rate = weapon.attack_cooldown
				projectile_shooter_component.knockback_force = weapon.knockback_force
				if weapon.attack_scene:
					projectile_shooter_component.standard_bullet_scene = weapon.attack_scene

			if melee_attack_component:
				melee_attack_component.process_mode = Node.PROCESS_MODE_DISABLED
