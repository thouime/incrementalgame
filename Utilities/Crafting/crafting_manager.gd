extends Node

signal build_object
signal stop_building

var preview_object : Node = null # Temporary "ghost" object that follos the mouse.
var items_to_remove : Dictionary
# Check if the grid is active
var grid_active : bool = false
var placement_mode : bool = false

# Necessary references to be initialized at runtime
var main : Node
var world : Node2D
var grass_tiles : TileMapLayer
var inventory : InventoryData
var grid : Control

func _process(_delta: float) -> void:
	# Get the cursor's global position
	if grid_active:
		draw_grid()

func _input(event: InputEvent) -> void:
	# Handle left mouse button press
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if grid_active and placement_mode:
				place_object()
		# Handle cancel action (e.g., pressing the "cancel" action key)
		elif event.is_action_pressed("cancel"):
			if grid_active:
				cancel_place_object()

func set_references(references : Dictionary) -> void:
	main = references["main"]
	world = references["world"]
	grass_tiles = references["grass_tiles"]
	inventory = references["inventory"]
	grid = references["grid"]

# Check if the player has the required materials in the player inventory
func try_craft(craft_slot: CraftData) -> void:
	var material_slots: Dictionary = {}
	var missing_materials: bool = false
	# Check for materials and quantities
	for craft_material in craft_slot.material_slot_datas:
		if craft_material:
			var inventory_slots: Dictionary = inventory.check_materials(
				craft_material.item_data, 
				craft_material.quantity
			)
			material_slots.merge(inventory_slots)
			if material_slots[craft_material.item_data]["missing"] > 0:
				missing_materials = true
	
	if not missing_materials:
		# Craft the materials
		craft(material_slots, craft_slot)
	else:
		# Print Missing materials
		print_missing(material_slots)

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

func craft(material_slots: Dictionary, craft_slot: CraftData) -> void:
	if craft_slot.type == craft_slot.Type.OBJECT:
		build_object.emit()
		print("Preparing grid...")
		var new_object: StaticBody2D = craft_slot.object_scene.instantiate()
		var sprite: Sprite2D = new_object.get_node("Sprite1")
		
		# Ensure unique material and shader
		if new_object.material:
			var new_material: ShaderMaterial = new_object.material.duplicate()
			if new_material.shader:
				new_material.shader = new_material.shader.duplicate()
			new_object.material = new_material
		
		preview_object = new_object
		items_to_remove = material_slots
		# Change the cursor to the sprite of the craft
		#grid.set_cursor(sprite)
		#draw_grid()

	elif craft_slot.type == craft_slot.Type.ITEM:
		var new_item: SlotData = craft_slot.slot_data.duplicate()
		# Try to add item to inventory, otherwise set it to null
		if inventory.pick_up_slot_data(new_item):
			inventory.remove_checked_items(material_slots)
			print("Item added to inventory.")
		else:
			new_item = null
	else:
		print("Craftable isn't assigned a type!")

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

func draw_grid() -> void:
	grid.draw_grid()
	grid.update_cursor()
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	grid.build_cursor.visible = true
	grid_active = true
	grid.visible = true
	placement_mode = true

func check_area(cursor_position: Vector2, grid_size: int) -> bool:
	# Define the area to check for overlapping objects
	var shape: RectangleShape2D = RectangleShape2D.new()
	shape.extents = Vector2(float(grid_size) / 2.0, float(grid_size) / 2.0)

	# Set up the physics query
	var space_state: PhysicsDirectSpaceState2D = (
		PlayerManager.player.get_world_2d().direct_space_state
	)
	var query: PhysicsShapeQueryParameters2D = (
		PhysicsShapeQueryParameters2D.new()
	)
	query.shape = shape
	query.transform = Transform2D(0, cursor_position)
	
	# Perform the physics query
	var results: Array = space_state.intersect_shape(query, 1)
	if results.size() > 0:
		print("There is an object in the way.")
	return results.size() == 0

func check_ground(
		cursor_position: Vector2, 
		tile_map_layer: TileMapLayer, 
		grid_size: int
	) -> bool:
	# Convert the world position to the local position relative to the tilemap
	var local_position: Vector2 = tile_map_layer.to_local(cursor_position)
	
	if grid_size > 16:
		# Calculate the top-left corner of the bounding box for the 32x32 object
		var top_left_cell: Vector2 = tile_map_layer.local_to_map(
			local_position - Vector2(
				float(grid_size) / 2.0, 
				float(grid_size) / 2.0
			)
		)
		# Calculate the number of cells to check in each direction (2 cells horizontally and vertically for a 32x32 object)
		var cells_to_check: Vector2 = Vector2(2, 2)
		
		# Loop through the affected cells and check if there's a tile at each position
		for x in range(top_left_cell.x, top_left_cell.x + cells_to_check.x):
			for y in range(top_left_cell.y, top_left_cell.y + cells_to_check.y):
				# Check if there's a tile at this position
				var data: TileData = tile_map_layer.get_cell_tile_data(Vector2i(x, y))
				
				if !data:  # If no tile data exists at this position
					print("There's no land to place on.")
					return false  # Return false immediately if no tile is found
				
				var tile_id: int = data.terrain
				
				# Check for specific tiles (e.g., ground or grass)
				if tile_id == 0:
					#print("Ground tile found at ", x, y)
					pass
				elif tile_id == 1:
					#print("Grass tile found at ", x, y)
					pass
				else:
					#print("Other tile found at ", x, y)
					pass
					
		# If all cells are valid, return true after all checks
		return true
	else:
		# For smaller grid sizes (e.g., <= 16), just check a single tile
		var clicked_cell: Vector2 = tile_map_layer.local_to_map(local_position)
		var data: TileData = tile_map_layer.get_cell_tile_data(clicked_cell)
		if data:
			var tile_id: int = data.terrain
			print(tile_id)
			return true
		else:
			print("There's no land to place on.")
			return false

func can_place(
	cursor_position: Vector2, 
	tilemap: TileMapLayer, 
	grid_size: int
) -> bool:
	return (check_area(cursor_position, grid_size) and 
			check_ground(cursor_position, tilemap, grid_size))
			
func place_object() -> void:
	if preview_object:
		# Check if object can be placed
		# Checks if attempting to place on void or another object
		if(!can_place(grid.get_cursor(), grass_tiles, 32)):
			return
		
		# Remove the required items to craft the object
		inventory.remove_checked_items(items_to_remove)
		items_to_remove.clear()


		# Set object position to the grid cursor position
		preview_object.position = grid.get_cursor()
		# Add the object to the world
		main.add_child(preview_object)
		preview_object.connect("interact", PlayerManager.state_machine._on_interact_signal)
		
		# Any external inventories need to be connected to inventory signal
		if preview_object.is_in_group("external_inventory"):
			preview_object.toggle_inventory.connect(main.toggle_inventory_interface)
		
		# Object was successfully placed, so we are done building
		stop_building.emit()
		
		# Shaders are disabled while building, this turns it back on
		preview_object.draw_shader(true)
		
		print("Object added to world.")

		# Reset the preview object for the next action
		preview_object = null

		# Change mouse mode back to visible
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		grid.build_cursor.visible = false

		# Deactivate grid and placement mode
		grid_active = false
		grid.visible = false
		placement_mode = false
	else:
		print("There is no reference to the object!")

func cancel_place_object() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	grid.build_cursor.visible = false
	grid_active = false
	grid.visible = false
	placement_mode = false

func _on_stop_building() -> void:
	cancel_place_object()
