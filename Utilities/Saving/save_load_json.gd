extends Button

const SAVE_PATH = "user://save_json.json"

var player_node: NodePath
# Keep a dictionary of all resource items to load them in the game
var items_by_name: Dictionary = {}

func _ready() -> void:
	player_node = PlayerManager.player.get_path()
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
			health = var_to_str(player.health),
			inventory = serialize_inventory(inventory_slots)
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
	player.health = str_to_var(save_dict.player.health)
	
	# Load inventory
	var inventory_array : Array = save_dict["player"]["inventory"]
	var inventory_data := deserialize_inventory(inventory_array)
	player_inventory.set_inventory_slots(inventory_data)
	
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
