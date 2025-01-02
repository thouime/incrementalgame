extends Button

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

	var player := get_node(player_node)
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
			tiles = player.placed_tiles
		}
	}
	# Save chest inventories
	
	file.store_line(JSON.stringify(save_dict))
	file.close()
	
	print("Game saved successfully!")
	
	get_node(^"../LoadJSON").disabled = false

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
		print(object_data)
		
		# Save specific data for unique objects 
		save_type_data(object, object_data)
		
		serialized_objects.append(object_data)
		# Gather time
		# if it has a drop table (like bush or tree)
		# External inventory if it has it
		# Fill status
	return serialized_objects

func save_type_data(object: StaticBody2D, object_data: Dictionary) -> void:
	match object_data["type"]:
		"External Inventory":
			var inventory = object.inventory_data.get_inventory_slots()
			var serialized_inventory = serialize_inventory(inventory)
			object_data["inventory"] = serialized_inventory
		"Processing":
			object_data["fill_status"] = object.current_amount

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
