extends Control

signal toggle_inventory
signal load_saves

@onready var v_box_container_left: VBoxContainer = $VBoxContainer/BottomHud/PanelContainer/MarginContainer/HBoxContainer/VBoxContainerLeft
@onready var v_box_container_right: VBoxContainer = $VBoxContainer/BottomHud/PanelContainer/MarginContainer/HBoxContainer/VBoxContainerRight
@onready var inventory_interface: Control = $VBoxContainer/BottomHud/PanelContainer/MarginContainer/HBoxContainer/PanelContainer/InventoryInterface
@onready var crafting_menu: PanelContainer = $VBoxContainer/BottomHud/PanelContainer/MarginContainer/HBoxContainer/PanelContainer/CraftingMenu
@onready var building_menu: PanelContainer = $VBoxContainer/BottomHud/PanelContainer/MarginContainer/HBoxContainer/PanelContainer/BuildingMenu
@onready var save_menu: PanelContainer = $VBoxContainer/BottomHud/PanelContainer/MarginContainer/HBoxContainer/PanelContainer/HubSaveMenu
@onready var menu_panel: Panel = $VBoxContainer/MarginContainer/TopHud/MenuPanel
@onready var save_list_menu: Control = $VBoxContainer/MarginContainer/TopHud/MenuPanel/VBoxContainer/SaveListMenu
@onready var settings_menu: Control = $VBoxContainer/MarginContainer/TopHud/MenuPanel/VBoxContainer/SettingsMenu
@onready var back_button: Button = $VBoxContainer/MarginContainer/TopHud/MenuPanel/VBoxContainer/BackButton

var hub_menus = []
var setting_menus = []
var buttons = []

func _ready() -> void:
	# All the small menus on the bottom screen hud
	hub_menus = [
		inventory_interface,
		crafting_menu,
		building_menu,
		save_menu
	]
	
	# Popup menus that will show if the user clicks certain setting buttons
	setting_menus = [
		save_list_menu,
		settings_menu
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
	inventory_interface.force_close.connect(close_external_inventory)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Non movement inputs
	if Input.is_action_just_pressed("inventory"):
		toggle_inventory.emit()
	if Input.is_action_just_pressed("toggle_menu"):
		for current_menu in hub_menus:
			current_menu.visible = false
		for button in buttons:
			button.button_pressed = false

func _input(event) -> void:
	if event.is_action_pressed("toggle_menu"):
		close_settings_menu()

# Turn off any visible menus and flip the visibility of the current menu
func toggle_hub_menu(menu: Control, clicked_button: Button) -> void:
	
	# If the inventory interface is open and has an external inventory, clear it
	if (
		inventory_interface.visible 
		and inventory_interface.has_external_inventory()
	):
		inventory_interface.clear_external_inventory()
	
	# Determine if the menu is currently open
	var is_menu_open = menu and menu.visible
	
	# Hide all menus
	for current_menu in hub_menus:
		current_menu.visible = false
	
	# Unpress all buttons
	for button in buttons:
		button.button_pressed = false
	
	if menu:
		menu.visible = not is_menu_open # Toggle visibility
		
		# Ensure button reflects new state
		clicked_button.button_pressed = menu.visible

# Open a larger menu that covers the screen and pause the game
func open_settings_menu(menu: Control) -> void:
	
	# If the inventory interface is open and has an external inventory, clear it
	if (
		inventory_interface.visible 
		and inventory_interface.has_external_inventory()
	):
		inventory_interface.clear_external_inventory()
	
	for current_menu in hub_menus:
		current_menu.visible = false
	
	# Pause the game
	get_tree().paused = true
	
	# Show a background panel behind the settings
	menu_panel.show()
	
	# Determine if the menu is currently open
	var is_menu_open = menu and menu.visible
	
	# Hide all menus
	for current_menu in setting_menus:
		current_menu.visible = false
	
	if menu:
		menu.visible = not is_menu_open # Toggle visibility

func close_settings_menu():
	
	menu_panel.hide()
	
	# Hide all menus
	for current_menu in setting_menus:
		current_menu.visible = false
	
	for button in buttons:
		button.button_pressed = false
	
	# Unpause the game
	get_tree().paused = false

func toggle_inventory_interface(external_inventory_owner: Node = null) -> void:
	# Check if opening or closing player inventory
	if external_inventory_owner:
		if (
			inventory_interface.visible 
			and inventory_interface.has_external_inventory()
		):
			return
		if inventory_interface.visible:
			inventory_interface.set_external_inventory(
				external_inventory_owner
			)
			return
		
		# Always set the external inventory if it's provided
		inventory_interface.set_external_inventory(external_inventory_owner)
		
		toggle_hub_menu(
			inventory_interface, 
			v_box_container_left.get_node("InventoryButton")
		)
	else:
		toggle_hub_menu(
			inventory_interface, 
			v_box_container_left.get_node("InventoryButton")
		)
		# Clear any external inventory if closing or only showing player inventory
		if not inventory_interface.visible:
			close_external_inventory()

func close_external_inventory():
	inventory_interface.clear_external_inventory()

func _on_inventory_button_pressed() -> void:
	toggle_hub_menu(
		inventory_interface, 
		v_box_container_left.get_node("InventoryButton")
	)

func _on_crafting_button_pressed() -> void:
	toggle_hub_menu(
		crafting_menu,
		v_box_container_left.get_node("CraftingButton")
	)

func _on_building_button_pressed() -> void:
	toggle_hub_menu(
		building_menu, 
		v_box_container_left.get_node("BuildingButton")
	)

func _on_save_button_pressed() -> void:
	toggle_hub_menu(
		save_menu, 
		v_box_container_right.get_node("SaveButton")
	)

func _on_load_button_pressed() -> void:
	open_settings_menu(save_list_menu)

func _on_audio_button_pressed() -> void:
	toggle_hub_menu(
		null, 
		v_box_container_right.get_node("AudioButton")
	)

func _on_settings_button_pressed() -> void:
	v_box_container_right.get_node("SettingsButton").button_pressed = true
	open_settings_menu(settings_menu)

func _on_back_button_pressed() -> void:
	close_settings_menu()
