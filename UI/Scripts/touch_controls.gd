extends Control

@onready var health_bar: HealthBarComponent = $CanvasLayer/PlayerHealthBar
@onready var inventory_grid: InventoryGridUI = $CanvasLayer/InventoryGrid
@onready var dash_button: Button = $DashButton
@onready var attack_button: Button = $AttackButton
@onready var inventory_button: Button = $InventoryButton # Or $CanvasLayer/InventoryButton if placed under CanvasLayer

func _ready() -> void:
	# Start with inventory hidden
	if inventory_grid:
		inventory_grid.visible = false

	# Connect toggle button
	if inventory_button:
		inventory_button.pressed.connect(toggle_inventory)

	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return

	if player.health_component:
		health_bar.setup(player.health_component)

	# --- Connect Inventory & Equipment UI ---
	var inventory: InventoryComponent = player.get_node_or_null("InventoryComponent")
	var equipment: EquipmentComponent = player.get_node_or_null("EquipmentComponent")
	if inventory_grid and inventory:
		inventory_grid.equipment_component = equipment
		inventory_grid.bind_inventory(inventory)

	var dash_component: DashComponent = player.get_node_or_null("DashComponent")
	if dash_component:
		dash_component.assign_button(dash_button)
	
	var melee_attack: MeleeAttackComponent = player.get_node_or_null("MeleeAttackComponent")
	if melee_attack:
		melee_attack.assign_button(attack_button)
	
	var shooter: ProjectileShooterComponent = player.get_node_or_null("ProjectileShooterComponent")
	if shooter:
		shooter.assign_button(attack_button)


func toggle_inventory() -> void:
	if inventory_grid:
		inventory_grid.visible = not inventory_grid.visible


## (Optional) Allows pressing "I" or "Tab" on PC/Keyboard to toggle
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		if event.keycode == KEY_I or event.keycode == KEY_TAB:
			toggle_inventory()
			get_viewport().set_input_as_handled()
