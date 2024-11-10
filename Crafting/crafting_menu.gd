extends PanelContainer

const Slot = preload("res://Crafting/crafting_slot.tscn")

# Small interface element that displays info about each craftable
const CRAFT_INFO = preload("res://Crafting/craft_info.tscn")

# For adding nodes to the scene
@onready var main: Node = $"../.."
@onready var crafting_grid: GridContainer = $MarginContainer/CraftingGrid
# For moving menus outside the PanelContainer
@onready var canvas_layer: CanvasLayer = $CanvasLayer

# All the different craftable items/objects
@export var craft_datas: Array[CraftData]

# Get a reference to the player's inventory for crafting
@onready var inventory = PlayerManager.player_inventory

# Flag to check if mouse is hovering over Craftables for more info
var craft_hovering = false

func _ready() -> void:
	populate_crafting_grid()

# Create the crafting grid for each craftable item
func populate_crafting_grid() -> void:
	for craft_data in craft_datas:
		var slot = Slot.instantiate()
		crafting_grid.add_child(slot)
		if craft_data:
			slot.set_craft_data(craft_data)
			add_info(craft_data)
		slot.craft_slot_clicked.connect(self.on_slot_clicked)
		slot.craft_slot_hovered.connect(self.on_slot_hovered)
		slot.craft_slot_exited.connect(self.on_slot_exited)

func add_info(craft_data: CraftData) -> void:
	# Create info interface that shows each type of material required
	var craft_info = CRAFT_INFO.instantiate()
	canvas_layer.add_child(craft_info)
	craft_info.set_info(craft_data)
	
	var materials = craft_data.material_slot_datas
	for material in materials:
		if material:
			craft_info.add_material(material.item_data, material.quantity)
			
	# Position craft_info window above crafting interface
	set_info_pos(craft_info)

func set_info_pos(craft_info: Control) -> void:
	var menu_position = self.global_position
	var menu_size = self.size
	var padding = 10
	var new_pos = craft_info.get_combined_minimum_size().y + padding
	craft_info.global_position = menu_position - Vector2(0, new_pos)

func show_craft_info(craft_slot: int) -> void:
	if not craft_hovering:
		craft_hovering = true
		var craft_info = canvas_layer.get_child(craft_slot)
		if craft_info:
			craft_info.show()
	
func hide_craft_info(craft_slot: int) -> void:
	if craft_hovering:
		craft_hovering = false
		var craft_info = canvas_layer.get_child(craft_slot)
		if craft_info:
			craft_info.hide()
			
func on_slot_clicked(craft_slot: int, button: int) -> void:
	try_craft(craft_datas[craft_slot])

# Check if you have required materials in inventory
# Maybe later it will automatically check external inventories like chests?
func try_craft(craft_slot: CraftData) -> void:
	var material_slots: Dictionary = {}
	var missing_materials = false
	
	# Check for materials and quantities
	for material in craft_slot.material_slot_datas:
		if material:
			var inventory_slots = inventory.check_materials(
				material.item_data, material.quantity
			)
			material_slots.merge(inventory_slots)
			if material_slots[material.item_data]["missing"] > 0:
				missing_materials = true
	
	if not missing_materials:
		# Print Missing materials
		craft(material_slots, craft_slot)
	else:
		# Craft the materials
		print_missing(material_slots)
		
func craft(material_slots: Dictionary, craft_slot: CraftData) -> void:
	if craft_slot.type == craft_slot.Type.OBJECT:
		inventory.remove_items(material_slots)
		var new_object = craft_slot.object_scene.instantiate()
		main.add_child(new_object)
		new_object.connect("interact", PlayerManager.player._on_interact_signal)
		new_object.position = Vector2(266, 550)
		print("Object added to world.")
	elif craft_slot.type == craft_slot.Type.ITEM:
		var new_item = craft_slot.slot_data.duplicate() # Set random quantity if needed
		# Try to add item to inventory, otherwise set it to null
		if inventory.pick_up_slot_data(new_item):
			inventory.remove_items(material_slots)
			print("Item added to inventory.")
		else:
			new_item = null
	else:
		print("Craftable isn't assigned a type!")

# Show a list of all the missing materials and the quantity needed
func print_missing(missing_materials: Dictionary) -> void:
	var missing_string = "Not enough materials to finish craft!\n" + \
							"Missing Materials:\n"
	
	for material in missing_materials.keys():
		var quantity = missing_materials[material]["missing"]
		if quantity > 0:
			missing_string += "     - " + material.name + ": x" + \
				str(quantity) + "\n"
	
	print(missing_string)

func on_slot_hovered(index: int):
	show_craft_info(index)

func on_slot_exited(index: int):
	hide_craft_info(index)
