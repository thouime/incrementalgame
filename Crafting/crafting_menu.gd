extends PanelContainer

const Slot = preload("res://Crafting/crafting_slot.tscn")

# For adding nodes to the scene
@onready var main: Node = $"../.."
@onready var crafting_grid: GridContainer = $MarginContainer/CraftingGrid
# For moving menus outside the PanelContainer
@onready var canvas_layer: CanvasLayer = $CanvasLayer

# All the different craftable items/objects
@export var craft_datas: Array[CraftData]

# Small interface element that displays info about each craftable
const CRAFT_INFO = preload("res://Crafting/craft_info.tscn")
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

func show_craft_info(index: int) -> void:
	if not craft_hovering:
		craft_hovering = true
		var craft_info = canvas_layer.get_child(index)
		if craft_info:
			craft_info.show()
	
func hide_craft_info(index: int) -> void:
	if craft_hovering:
		craft_hovering = false
		var craft_info = canvas_layer.get_child(index)
		if craft_info:
			craft_info.hide()
			
func on_slot_clicked(index: int, button: int) -> void:
	var inventory = PlayerManager.player_inventory
	# Check if you have required materials in inventory
	# Maybe later it will automatically check external inventories like chests?
	# Get craft clicked, get materials, check if materials are in inventory
	var current_craft = craft_datas[index]
	var material_slots: Dictionary = {}
	var enough_materials = true
	for material in current_craft.material_slot_datas:
		if material:
			var inventory_slots = inventory.check_total_materials(
									material.item_data, material.quantity)
			if inventory_slots:
				if not material in material_slots:
					material_slots[material] = {
						"slots": []
					}
				material_slots[material]["slots"] = inventory_slots
			else:
				print("There's not enough ", material.item_data.name, "s for crafting!")
				enough_materials = false
				break
	if enough_materials:
		# Remove all the required items
		# Check if it's an object or item and then add it
		# Need to add more logic for adding objects
		if current_craft.type == current_craft.Type.OBJECT:
			inventory.reduce_slot_datas(material_slots)
			var new_object = current_craft.object_scene.instantiate()
			main.add_child(new_object)
			new_object.connect("interact", PlayerManager.player._on_interact_signal)
			new_object.position = Vector2(266, 550)
			print("This is an object.")
		elif current_craft.type == current_craft.Type.ITEM:
			print("This is an item.")
			var new_item = current_craft.slot_data.duplicate() # Set random quantity if needed
			# Try to add item to inventory, otherwise set it to null
			if inventory.pick_up_slot_data(new_item):
				inventory.reduce_slot_datas(material_slots)
				print("Item added to inventory.")
			else:
				new_item = null
		else:
			print("Craft isn't assigned a type!")
	else:
		print("Not enough materials!")
			
	
func on_slot_hovered(index: int):
	show_craft_info(index)

func on_slot_exited(index: int):
	hide_craft_info(index)
