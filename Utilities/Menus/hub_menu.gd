extends Control

signal toggle_inventory

@onready var inventory_interface: Control = $PanelContainer/MarginContainer/HBoxContainer/PanelContainer/InventoryInterface
@onready var crafting_menu: PanelContainer = $PanelContainer/MarginContainer/HBoxContainer/PanelContainer/CraftingMenu
@onready var building_menu: PanelContainer = $PanelContainer/MarginContainer/HBoxContainer/PanelContainer/BuildingMenu2
@onready var v_box_container_left: VBoxContainer = $PanelContainer/MarginContainer/HBoxContainer/VBoxContainerLeft
@onready var v_box_container_right: VBoxContainer = $PanelContainer/MarginContainer/HBoxContainer/VBoxContainerRight

var menus = []
var buttons = []

func _ready() -> void:
	menus = [
		inventory_interface, 
		crafting_menu, 
		building_menu
	]
	
	for button in v_box_container_left.get_children():
		buttons.append(button)
		
	for button in v_box_container_right.get_children():
		buttons.append(button)
		
	toggle_inventory.connect(toggle_inventory_interface)
	inventory_interface.set_player_inventory_data(
		PlayerManager.player.inventory_data)
	inventory_interface.set_equip_inventory_data(
		PlayerManager.player.equip_inventory_data)
	inventory_interface.force_close.connect(toggle_inventory_interface)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Non movement inputs
	if Input.is_action_just_pressed("inventory"):
		toggle_inventory.emit()
	if Input.is_action_just_pressed("toggle_menu"):
		for current_menu in menus:
			current_menu.visible = false
		for button in buttons:
			button.button_pressed = false

# Turn off any visible menus and flip the visibility of the current menu
func toggle_menu(menu: Control, clicked_button: Button) -> void:
	
	# Hide all menus
	for current_menu in menus:
		if current_menu != menu:
			current_menu.visible = false
	
	for button in buttons:
		if button != clicked_button:
			button.button_pressed = false
	
	if not menu:
		return
	
	menu.visible = !menu.visible

func toggle_inventory_interface(external_inventory_owner: Node = null) -> void:
	# Check if opening or closing player inventory
	if external_inventory_owner:
		# Always set the external inventory if it's provided
		inventory_interface.set_external_inventory(external_inventory_owner)
		inventory_interface.visible = true  # Ensure it opens if interacting with external
	else:
		# Toggle only the player's inventory visibility
		inventory_interface.visible = not inventory_interface.visible
		# Clear any external inventory if closing or only showing player inventory
		if not inventory_interface.visible:
			inventory_interface.clear_external_inventory()

func _on_inventory_button_pressed() -> void:
	toggle_menu(
		inventory_interface, 
		v_box_container_left.get_node("InventoryButton")
	)

func _on_crafting_button_pressed() -> void:
	toggle_menu(
		crafting_menu,
		v_box_container_left.get_node("CraftingButton")
	)

func _on_building_button_pressed() -> void:
	toggle_menu(
		building_menu, 
		v_box_container_left.get_node("BuildingButton")
	)

func _on_save_button_pressed() -> void:
	toggle_menu(
		null, 
		v_box_container_right.get_node("SaveButton")
	)

func _on_audio_button_pressed() -> void:
	toggle_menu(
		null, 
		v_box_container_right.get_node("AudioButton")
	)

func _on_settings_button_pressed() -> void:
	toggle_menu(
		null, 
		v_box_container_right.get_node("SettingsButton")
	)
