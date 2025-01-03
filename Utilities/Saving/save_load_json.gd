extends Node

const SAVE_PATH = "user://save_json.json"

var player_node: NodePath
# Keep a dictionary of all resource items to load them in the game
var items_by_name: Dictionary = {}
var main: Node
# Keep track of any objects that were already loaded when loading again
var loaded_objects: Array = []

func _ready() -> void:
	player_node = PlayerManager.player.get_path()
	main = get_tree().current_scene
	load_all_items()
	
func save_game() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)

	var player := PlayerManager.player
	var player_inventory : InventoryData = player.inventory_data
	var inventory_slots := player_inventory.get_inventory_slots()
	# JSON doesn't support many of Godot's types such as Vector2.
	# var_to_str can be used to convert any Variant to a String.
	var save_dict := {
		player = {
			position = var_to_str(player.position),
			direction = var_to_str(player.direction),
			animation = player.animated_sprite.animation,
			health = var_to_str(player.health),
			inventory = serialize_inventory(inventory_slots)
		},
		world = {
			# Save all placed objects in the game
			objects = save_objects(),
			tiles = save_tiles(player.placed_tiles)
		}
	}
	# Save chest inventories
	
	file.store_line(JSON.stringify(save_dict))
	file.close()
	
	print("Game saved successfully!")

func serialize_inventory(slot_datas: Array) -> Array:
	var serialized_inventory := []
	for slot_data: SlotData in slot_datas:
		# If the inventory slot is empty, add it as null
		if not slot_data:
			serialized_inventory.append(null)
			continue
		serialized_inventory.append({
			"item_name": slot_data.item_data.name,
			"quantity": slot_data.quantity,
			"stackable": slot_data.item_data.get_stackable()
		})
	return serialized_inventory

# Save all objects in the game
func save_objects() -> Array:
	var save_objects = get_tree().get_nodes_in_group("Persist")
	var serialized_objects := []
	for object in save_objects:
		# Objects that are placed by the editor do not need to be saved/loaded
		if not object.player_generated:
			continue
		var object_name = object.get_object_name()
		var object_data := {
			"id": object.object_id,
			"name": object_name,
			"type": object.get_object_type(),
			"position": var_to_str(object.position),
			"scale": var_to_str(object.scale)
		}
		
		# Save specific data for unique objects 
		save_type_data(object, object_data)
		
		serialized_objects.append(object_data)
		
		save_tiles(PlayerManager.player.placed_tiles)
	return serialized_objects

func save_type_data(object: StaticBody2D, object_data: Dictionary) -> void:
	match object_data["type"]:
		"External Inventory":
			var inventory = object.inventory_data.get_inventory_slots()
			var serialized_inventory = serialize_inventory(inventory)
			object_data["inventory"] = serialized_inventory
		"Processing":
			object_data["fill_status"] = object.current_amount

func save_tiles(tiles: Dictionary) -> Dictionary:
	var serialized_tiles = {
		"grass": {},
		"boundary": {}
	}
	for tile_map in tiles.keys():
		for atlas_coords in tiles[tile_map].keys():
			var data = tiles[tile_map][atlas_coords]
			
			# If the atlas coordinates don't exist yet in grass or boundary, initialize them
			if not serialized_tiles["grass"].has(str(atlas_coords)):
				serialized_tiles["grass"][str(atlas_coords)] = []
			if not serialized_tiles["boundary"].has(str(atlas_coords)):
				serialized_tiles["boundary"][str(atlas_coords)] = []
			
			# Add serialized tile coordinates under "grass"
			if data.has("tiles"):
				for coord in data["tiles"]:
					serialized_tiles["grass"][str(atlas_coords)].append(str(coord))
			
			# Check if "boundary" key exists before accessing it
			if data.has("boundary"):
				# Add serialized boundary coordinates under "boundary"
				for coord in data["boundary"]:
					serialized_tiles["boundary"][str(atlas_coords)].append(str(coord))
			else:
				print("Warning: 'boundary' key is missing for atlas_coords:", atlas_coords)
	
	# Return the final dictionary with "grass" and "boundary" directly under "tiles"
	return serialized_tiles


func load_game() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		print("Save file not found!")
		return
		
	var json := JSON.new()
	json.parse(file.get_line())
	var save_dict := json.get_data() as Dictionary
	
	var player := get_node(player_node) as Player
	var player_inventory : InventoryData = player.inventory_data
	# JSON doesn't support many of Godot's types such as Vector2.
	# str_to_var can be used to convert a String to the corresponding 
	player.position = str_to_var(save_dict.player.position)
	if save_dict["player"].has("animation"):
		player.animated_sprite.animation = save_dict.player.animation
		player.direction = str_to_var(save_dict.player.direction)
		# Flip the sprite if facing left
		if player.velocity.x != 0:
			player.animated_sprite.flip_h = player.velocity.x < 0
	player.health = str_to_var(save_dict.player.health)
	
	# Load inventory
	var inventory_array : Array = save_dict["player"]["inventory"]
	var inventory_data := deserialize_inventory(inventory_array)
	player_inventory.set_inventory_slots(inventory_data)
	
	load_objects(save_dict.world.objects)
	
	load_tiles(save_dict.world.tiles)
	
	print("Game loaded successfully!")

func deserialize_inventory(
	serialized_inventory: Array
) -> Array[SlotData]:
	var deserialized_slots : Array[SlotData] = []
	for slot_data: Variant in serialized_inventory:
		var slot := SlotData.new()
		if not slot_data:
			deserialized_slots.append(null)
			continue
		var item := get_item_by_name(slot_data["item_name"])
		slot.set_item(item)
		slot.set_quantity(slot_data["quantity"])
		slot.item_data.set_stackable(slot_data["stackable"])
		deserialized_slots.append(slot)
	return deserialized_slots

# Load all the objects in the game
func load_objects(serialized_objects: Array) -> void:
	clear_loaded_objects()
	for object_data in serialized_objects:
		create_object(object_data)
			
# Clear all player made objects before loading them in
func clear_loaded_objects() -> void:
	for child in main.get_children():
		if not child.has_method("get_player_generated"):
			continue
		if child.get_player_generated():
			print("Queueing Free Object...")
			child.queue_free()

func find_object_by_id(object_id: int) -> Node:
	for object in loaded_objects:
		if object.object_id == object_id:
			return object
	return null

func create_object(object_data: Dictionary) -> void:
	# Get object scene from objects folder
	var objects_path = "res://Entities/Objects/"
	var object_path: String = objects_path + object_data.name + ".tscn"
	var packed_scene = load(object_path)
	
	# If the file path is incorrect
	if not packed_scene:
		print("Could not find scene file for object!")
		return
		
	var new_object: StaticBody2D = packed_scene.instantiate()

	# Set properites of object
	add_shaders(new_object)
	new_object.position = str_to_var(object_data.position)
	new_object.scale = str_to_var(object_data.scale)
	new_object.player_generated = true
	new_object.connect("interact", PlayerManager.state_machine._on_interact_signal)
	
	# Add to scene and initialize
	main.add_child(new_object)
	
	# Need the objects to run _ready initialization before running this
	load_type_data(new_object, object_data)
	
	loaded_objects.append(new_object)
	
	print("Object added to world.")

func load_type_data(object: StaticBody2D, object_data: Dictionary) -> void:
	match object_data.type:
		"External Inventory":
			# Load inventory
			var inventory_array : Array = object_data.inventory
			var inventory_data := deserialize_inventory(inventory_array)
			object.inventory_data.set_inventory_slots(inventory_data)
			object.toggle_inventory.connect(
				main.toggle_inventory_interface
			)
			print("External Inventory connected")
		"Processing":
			# Load fill status
			if object_data.fill_status > 0:
				object.set_current_amount(object_data.fill_status)

func add_shaders(new_object: StaticBody2D) -> void:
	if new_object.material:
		var new_material: ShaderMaterial = new_object.material.duplicate()
		if new_material.shader:
			new_material.shader = new_material.shader.duplicate()
		new_object.material = new_material

func load_tiles(placed_tiles: Dictionary) -> void:
	var world = get_node("/root/Main/World")
	var grass: TileMapLayer
	var boundary: TileMapLayer
	var tiles_to_build: Array
	var boundary_tiles: Array
	var grass_atlas: Vector2
	var boundary_atlas: Vector2
	
	for tile_map_name in placed_tiles.keys():
		var tile_map = world.get_node(tile_map_name.capitalize())
		if tile_map_name == "boundary": 
			boundary = tile_map
		
		for atlas_coord_str in placed_tiles[tile_map_name].keys():
			var atlas_coord = str_to_vector2i(atlas_coord_str)
			var data = placed_tiles[tile_map_name][atlas_coord_str]
			if tile_map_name == "grass" and atlas_coord == Vector2i(2,1):
				tiles_to_build = data
				grass = tile_map
				grass_atlas = atlas_coord
			if tile_map_name == "boundary" and atlas_coord == Vector2i(0,1):
				boundary_tiles = data
				boundary_atlas = atlas_coord
			# Load tiles
			for tile_str in data:
				var tile_coord = str_to_vector2i(tile_str)
				if tile_map_name == "grass":
					remove_boundary(tile_coord, boundary)
				tile_map.set_cell(
					tile_coord,
					0,
					atlas_coord
				)
	store_placed_tiles(
		tiles_to_build,
		grass,
		boundary_tiles,
		[],
		grass_atlas,
		boundary_atlas
	)

func remove_boundary(
	position: Vector2i,
	tiles: TileMapLayer
) -> void:
	var data: TileData = tiles.get_cell_tile_data(position)
	if data:
		# If a boundary tile is found, remove it by setting it to an invalid tile ID (e.g., -1)
		print("Removing boundary tile at position: (", position.x, ", ", position.y, ")")
		# Remove from boundary list
		tiles.set_cell(position, -1)  # Set the tile to empty

func store_placed_tiles(
	tiles_to_build: Array, 
	tile_map: TileMapLayer,
	placed_boundary_tiles: Array,
	removed_boundary_tiles: Array,
	atlas_coords: Vector2i,
	boundary_atlas: Vector2i
) -> void:
	var placed_tiles = PlayerManager.player.placed_tiles
	
	# Add dictionary key if it doesn't exist
	if not placed_tiles.has(tile_map):
		placed_tiles[tile_map] = {}
	# Add key for atlas_coords if it doesn't exist
	if not placed_tiles[tile_map].has(atlas_coords):
		placed_tiles[tile_map][atlas_coords] = {
			"tiles": tiles_to_build.duplicate()
		}
	
	# Add key for boundary_atlas if it doesn't exist
	if not placed_tiles[tile_map].has(boundary_atlas):
		placed_tiles[tile_map][boundary_atlas] = {
			"boundary": placed_boundary_tiles.duplicate()
		}
	
	else:
		var existing_data = placed_tiles[tile_map][atlas_coords]
		if not placed_tiles[tile_map][boundary_atlas].has("boundary"):
			return
		var existing_boundaries = placed_tiles[tile_map][boundary_atlas]["boundary"]

		for tile in removed_boundary_tiles:
			if tile in existing_boundaries: 
				existing_boundaries.erase(tile)
		
		# Merge main tiles
		var existing_tiles = existing_data["tiles"]
		existing_data["tiles"] = merge_array(tiles_to_build, existing_tiles)
		
		# Merge boundary tiles
		for new_tile in placed_boundary_tiles:
			if not existing_boundaries.has(new_tile):
				existing_boundaries.append(new_tile)

		# Update the dictionary
		placed_tiles[tile_map][atlas_coords] = existing_data
		placed_tiles[tile_map][boundary_atlas]["boundary"] = existing_boundaries

func merge_array(array_one: Array, array_two: Array) -> Array:
	var new_array = array_one.duplicate()
	for item in array_two:
		if not array_one.has(item):
			new_array.append(item)
	return new_array

func str_to_vector2i(vector_str: String) -> Vector2i:
	var cleaned_str = vector_str.replace("(", "").replace(")", "")
	var coords = cleaned_str.split(",")
	var restored_vector = Vector2i(coords[0].to_int(), coords[1].to_int())
	return restored_vector

# Get references to item resourcef files
func load_all_items() -> void:
	var item_path: String = "res://Entities/Item/Items/"
	load_items_in_directory(item_path)

# Function to recursively search and load items in the directory
func load_items_in_directory(current_path: String) -> void:
	var directory:= DirAccess.open(current_path)  # Create a new DirAccess for each call
	
	if not directory:
		print("Directory not found: %s" % current_path)
		return
	
	directory.list_dir_begin()

	var file_name: String = directory.get_next()
	while file_name != "":
		var full_path: String = current_path + file_name
		
		# If it's a directory, recursively search it
		if directory.current_is_dir():
			# Skip "." and ".." directories
			if file_name != "." and file_name != "..":
				load_items_in_directory(full_path + "/")  # Recurse into subdirectory
		elif file_name.ends_with(".tres"):
			# Load the item resource if it's a .tres file
			var item_resource:= load(full_path) as ItemData
			if item_resource:
				items_by_name[item_resource.name] = item_resource
		
		file_name = directory.get_next()
	
	directory.list_dir_end()

# Get the item by passing in the name
func get_item_by_name(item_name: String) -> ItemData:
	return items_by_name.get(item_name, null)
