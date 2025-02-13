extends Node

signal build_object
signal stop_building

var preview_object : Node = null # Temporary "ghost" object that follos the mouse.
var items_to_remove : Dictionary
# Check if the grid is active
var grid_active : bool = false
var placement_mode : bool = false

# Check if player has required materials for the craft
func can_craft(craft_slot: CraftData, inventory: InventoryData) -> bool:
	var required_materials = craft_slot.material_slot_datas
	# Get the dictionary with the inventory's item information
	var item_inventory = inventory.item_inventory
	# Create a dictionary of all the missing materials
	var missing_materials := {}
	
	for material in required_materials:
		# If it's null, skip to next material
		if not material:
			continue
			
		var material_name = material.item_data.name
		var material_quantity = material.quantity

		# Check if any items are in item_inventory dictionary
		if not item_inventory.has(material_name):
			missing_materials[material_name] = material_quantity
			continue
		
		var inventory_item = item_inventory[material_name]
		var total_item_quantity = inventory_item["total_quantity"]
		
		# If the player does have some of the item, but not enough
		if total_item_quantity < material_quantity:
			var quantity_needed = material_quantity - total_item_quantity
			missing_materials[material_name] = quantity_needed
			continue
	
	# Print missing materials if any
	if missing_materials.size() > 0:
		print_missing(missing_materials)
		return false

	# If all checks passed, there must be enough materials
	return true

# Show a list of all the missing materials and the quantity needed
func print_missing(missing_materials: Dictionary) -> void:
	var missing_string: String = (
		"Not enough materials to craft!\n" +
		"Missing Materials:\n"
	)

	for missing_material: String in missing_materials:
		var quantity: int = missing_materials[missing_material]
		if quantity > 0:
			missing_string += (
				"     - " + 
				missing_material + ": x" + 
				str(quantity) + "\n"
			)
	
	print(missing_string)

# Craft an item to be added to an inventory
func craft(craft_slot: CraftData, inventory: InventoryData) -> void:
	# Redundancy safeguard to make sure crafting is possible
	if not can_craft(craft_slot, inventory):
		return
	var materials_to_remove: Array = craft_slot.material_slot_datas
	# remove each item required for the craft
	for material in materials_to_remove:
		inventory.remove_item(material.item_data.name, material.quantity)
	var new_item: SlotData = craft_slot.slot_data.duplicate()

	# Try to add item to inventory, otherwise set it to null
	if inventory.pick_up_slot_data(new_item):
		#inventory.remove_checked_items(material_slots)
		print("Item added to inventory.")
	else:
		new_item = null

# Craft an object to be added and placed in the world
func build(craft_slot: CraftData) -> void:
	# create new object
	# enable unique material and shader for object
	# set preview object to new object
	# add the items that will be removed to a dictionary/array
	# set the cursor to the sprite of the object
	# draw grid
	# check if the object can be placed
	# 	- Is there other objects in the way
	#	- Is there land under the object
	# place object
	
	#if craft_slot.type == craft_slot.Type.OBJECT:
		#build_object.emit()
		#print("Preparing grid...")
		#var new_object: StaticBody2D = craft_slot.object_scene.instantiate()
		#var sprite: Sprite2D = new_object.get_node("Sprite1")
		#
		## Ensure unique material and shader
		#if new_object.material:
			#var new_material: ShaderMaterial = new_object.material.duplicate()
			#if new_material.shader:
				#new_material.shader = new_material.shader.duplicate()
			#new_object.material = new_material
		#
		#preview_object = new_object
		#items_to_remove = material_slots
		## Change the cursor to the sprite of the craft
		##grid.set_cursor(sprite)
		##draw_grid()
	pass
