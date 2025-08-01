extends Node

signal start_building
signal stop_building

# Temporary "ghost" object that follows the mouse.
var preview_object : Node = null
# Object for placing automating machines on
var source_object : Node2D = null
# Object for receiving input
var target_object : Node2D = null
var items_to_remove : Dictionary
# Check if the grid is active
var grid_active : bool = false
var placement_mode : bool = false

# Necessary references to be initialized at runtime
var main : Node
var world : Node2D
var grass_tiles : TileMapLayer
var boundary_tiles : TileMapLayer
var inventory : InventoryData
var hub_menu : Control
var grid : Control

func _process(_delta: float) -> void:
	# Get the cursor's global position
	if grid_active:
		draw_grid()

func _input(event: InputEvent) -> void:
	if not event is InputEventMouseButton:
		return
	
	if event.button_index != MOUSE_BUTTON_LEFT or not event.pressed:
		return
		
	if not (grid_active and placement_mode):
		return
	
	if preview_object.object_type == "automation":
		
		if preview_object.object_name == "connector":
			if not can_object_transfer(grid.get_cursor(), 32):
				return
			
			# We already have a target object, now set input object
			if source_object:
				if not can_object_transfer(grid.get_cursor(), 32):
					return
				place_connector()
			
			return
		
		can_object_automate(grid.get_cursor(), 32)
		place_automated_object()
		return
		
	else: 
		place_object()
		
	# Handle cancel action (e.g., pressing the "cancel" action key)
	if event.is_action_pressed("cancel") and grid_active:
		cancel_place_object()

func set_references(references : Dictionary) -> void:
	main = references["main"]
	world = references["world"]
	grass_tiles = references["grass_tiles"]
	boundary_tiles = references["boundary_tiles"]
	inventory = references["inventory"]
	grid = references["grid"]
	hub_menu = references["hub_menu"]

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

func craft(material_slots: Dictionary, craft_slot: CraftData) -> void:
	if craft_slot.type == craft_slot.Type.OBJECT:
		start_building.emit()
		print("Preparing grid...")
		var new_object: Variant = craft_slot.object_scene.instantiate()
		var sprite: Sprite2D = new_object.get_node("Sprite1")
		
		# Ensure unique material and shader
		if new_object.material:
			var new_material: ShaderMaterial = new_object.material.duplicate()
			if new_material.shader:
				new_material.shader = new_material.shader.duplicate()
			new_object.material = new_material
		
		new_object.initialize()
		preview_object = new_object
		items_to_remove = material_slots
		# Change the cursor to the sprite of the craft
		grid.set_cursor(sprite)
		draw_grid()

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
		"Not enough materials to finish craft!\n" +
		"Missing Materials:\n"
	)

	for missing_material: ItemData in missing_materials.keys():
		var quantity: int = missing_materials[missing_material]["missing"]
		if quantity > 0:
			missing_string += (
				"     - " + 
				missing_material.name + ": x" + 
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
	
	var objects_underneath : Array = (
		get_underlying_objects(cursor_position, grid_size)
	)
	
	return objects_underneath.size() == 0

func get_underlying_objects(cursor_position: Vector2, grid_size: int) -> Array:
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
	
	return results

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

func can_object_automate(cursor_position: Vector2, grid_size: int) -> bool:
	var results : Array = get_underlying_objects(cursor_position, grid_size)
	var object : Node2D
	for result : Dictionary in results:
		
		if result.has("collider"):
			object = result["collider"]
		
		if not object or not object is GatheringInteract:
			print("continuing, object: ", object)
			continue
			
		# Check if object already has a harvester
		if not object.harvester:
			source_object = object
			return true
			
		print("Object already has a harvester!")
		return false
	return false

func can_object_transfer(cursor_position: Vector2, grid_size: int) -> bool:
	var results : Array = get_underlying_objects(cursor_position, grid_size)
	var object : Node2D
	for result : Dictionary in results:
		
		if result.has("collider"):
			object = result["collider"]
		
		if object is TileMapLayer:
			continue

		if object.get("connector"):
			print("Object already has a connector!")
			return false
		
		if object is GatheringInteract:
			print("Object is a gathering type")
			# only output to a chest
			if source_object:
				printerr("Gathering Objects can't receive input!")
				return false
			
			source_object = object
			return true
		
		if object.object_name == "chest":
			print("Object is a chest")
			if source_object:
				if source_object.object_name == "chest":
					printerr("Can't connect a chest to a chest!")
					return false
				target_object = object
				return true
			else:
				source_object = object
				var sprite: Sprite2D = preview_object.get_node("TargetSprite")
				grid.set_cursor(sprite)
				return true
		
		if object.object_type == "Processing":
			print("Object is a processing type")
			# Processing types don't have inventories
			if source_object:
				target_object = object
			else:
				source_object = object
				
			return true

		# Check if object already has a connector
		if not object.get("connector"):
			source_object = object
			return true
			
		print("Can't place connector on object!")
		return false
	return false

func place_object() -> void:
	if not preview_object:
		print("There is no reference to the object!")
		return
	# Check if object can be placed
	# Checks if attempting to place on void or another object
	if(!can_place(grid.get_cursor(), grass_tiles, 32)):
		return
	
	# Set object position to the grid cursor position
	preview_object.position = grid.get_cursor()
	
	setup_object()

func place_automated_object() -> void: 
	if not preview_object:
		print("There is no reference to the object!")
		return
	
	if not source_object:
		printerr("No target object for automation!")
		return
	
	var sprite: Sprite2D = source_object.get_node("Sprite1")
	var center_position: Vector2 = sprite.global_position
	# Set object position to the grid cursor position
	preview_object.position = center_position
	
	# If it's a harvester automation object
	# Give each object a reference to eachother
	if preview_object.object_name == "harvester":
		source_object.harvester = preview_object
		preview_object.gathering_object = source_object
	
	setup_object()

func place_connector() -> void:

	if not (source_object and target_object):
		printerr("Need both a target object and target input!")
		return
		
	# 5 tiles distance
	var max_distance : float = 128
	var distance : float = (
		source_object.position.distance_to(target_object.position)
	)
	
	if distance > max_distance:
		print("Objects are too far apart, must be less than: ", max_distance)
		return
	
	source_object.connector = preview_object
	target_object.connector = preview_object
	
	preview_object.source_object = source_object
	preview_object.target_object = target_object
	
	setup_object()
	
func setup_object() -> void:
	# Remove the required items to craft the object
	inventory.remove_checked_items(items_to_remove)
	items_to_remove.clear()

	# Keep track of objects created by the player for saving
	preview_object.player_generated = true
	# Add the object to the world
	main.add_child(preview_object)
	# Set unique identifier for the object instance (for saving/loading)
	preview_object.object_id = preview_object.get_instance_id()
	
	if not preview_object.object_type == "automation":
		preview_object.connect(
			"interact", PlayerManager.state_machine._on_interact_signal
		)
	
	# Any external inventories need to be connected to inventory signal
	if preview_object.is_in_group("external_inventory"):
		preview_object.toggle_inventory.connect(
			hub_menu.toggle_inventory_interface
		)
	
	# Object was successfully placed, so we are done building
	stop_building.emit()
	
	print("Object added to world.")

	# Change mouse mode back to visible
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	grid.build_cursor.visible = false

	# Shaders are disabled while building, this turns it back on
	preview_object.draw_shader(true)

	# Deactivate grid and placement mode
	grid_active = false
	grid.visible = false
	placement_mode = false
	
	# Clear references to objects
	preview_object = null
	source_object = null
	target_object = null
	
func cancel_place_object() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	grid.build_cursor.visible = false
	grid_active = false
	grid.visible = false
	placement_mode = false
	source_object = null
	target_object = null

func _on_stop_building() -> void:
	cancel_place_object()
