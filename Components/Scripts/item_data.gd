class_name ItemData
extends Resource

enum ItemType {
	GENERIC,
	CONSUMABLE,
	EQUIPMENT,
	AMMO
}

enum EquipmentSlotType {
	NONE,
	MAIN_HAND, ## Swords, Bows, Staffs
	OFF_HAND,  ## Shields, Quivers
	AMMO,      ## Arrows, Bullets
	ARMOR      ## Chest armor
}

enum WeaponType {
	NONE,
	MELEE,
	RANGED
}

@export_group("Basic Info")
@export var id: StringName = &""
@export var name: String = "Item"
@export_multiline var description: String = ""
@export var icon: Texture2D

@export_group("Stacking")
@export var is_stackable: bool = false
@export_range(1, 999, 1) var max_stack_size: int = 99

@export_group("Classification")
@export var item_type: ItemType = ItemType.GENERIC
@export var equipment_slot: EquipmentSlotType = EquipmentSlotType.NONE

@export_group("Equipment & Combat Attributes")
@export var weapon_type: WeaponType = WeaponType.NONE
@export var damage: float = 10.0
@export var attack_cooldown: float = 0.35
@export var knockback_force: float = 200.0
@export var attack_scene: PackedScene ## Slash effect for sword or Arrow scene for bow
@export var required_ammo_id: StringName = &"" ## e.g., &"arrow_wooden" for Bows
