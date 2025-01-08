extends Resource
class_name InventoryData

signal inventory_interact(inventory_data: InventoryData, index: int, button: int)
signal inventory_updated(inventory_data: InventoryData)

@export var slot_datas: Array[SlotData]

# Inventory Dictionary Structure for Item Tracking
# The dictionary is structured as followsd:
#	item_name (key): String representing each item
#		-> item_slots (key): Diciontary for each slot index in inventory
#			-> slot_index (key): Represents index of the slot (e.g. 0, 1, 2)
#				-> slot_data (key): Reference to slot data holding item info
#				-> quantity (key): Quantity of item for this slot
#		-> total_quantity (key): Total quantity of the item
var item_inventory: Dictionary

func initialize_slots(size: int, default_value: Variant = null) -> void:
	slot_datas = []
	for i in range(size):
		slot_datas.append(default_value)

func setup_item_inventory() -> void:
	for slot_index in range(slot_datas.size()):
		var slot_data = slot_datas[slot_index]
		if not slot_data:
			continue
		add_inventory_entry(slot_data, slot_index)

# Update item_inventory dictionary or add new entry if it doesn't exist
func add_inventory_entry(slot_data: SlotData, slot_index: int) -> void:
	var item_data = slot_data.item_data
	var item_name = item_data.name
	
	# Initialize item entry in the inventory if it doesn't exist
	if not item_inventory.has(item_name):
		item_inventory[item_name] = {
			"item_slots": {},
			"total_quantity": 0
		}
	
	var item_entry = item_inventory[item_name]
	var item_index = item_entry["item_slots"]
	
	# Initialize the slot entry for this index if it doesn't exist
	if not item_index.has(slot_index):
		# Update or add the new slot for the item
		item_index[slot_index] = {
			"slot_data": slot_data,
			"quantity":  0
		}

	# Update the quantities for that item and item's slot
	item_index[slot_index]["quantity"] += slot_data.quantity
	item_entry["total_quantity"] += slot_data.quantity

func remove_inventory_entry(
	slot_data: SlotData, 
	slot_index: int, 
	remove_quantity: int
) -> void:
	var item_data = slot_data.item_data
	var item_name = item_data.name
	
	if not item_inventory.has(item_name):
		push_error("No item with that name in the inventory!")
		return
	
	var item_entry = item_inventory[item_name]
	
	if not item_entry["item_slots"].has(slot_index):
		# Update or add the new slot for the item
		push_error("No item in that index!")
		return
		
	# Update the quantities for that item and item's slot
	item_entry["item_slots"][slot_index]["quantity"] -= remove_quantity
	item_entry["total_quantity"] -= remove_quantity
	
	# Remove the index key from the dictionary if there's no items left
	if item_entry["item_slots"][slot_index]["quantity"] <= 0:
		item_entry["item_slots"].erase(slot_index)
	
	if item_entry["item_slots"].size() == 0:
		item_inventory.erase(item_name)

func get_slot_datas() -> Array[SlotData]:
	return slot_datas
	
func get_item_datas() -> Array[ItemData]:
	var item_datas: Array[ItemData] = []
	for slot in get_slot_datas():
		if not slot:
			continue
		item_datas.append(slot.item_data)
	return item_datas

# Grab slot with cursor or other means
func grab_slot_data(index: int) -> SlotData:
	var slot_data: SlotData = slot_datas[index]
	
	if slot_data:
		slot_datas[index] = null
		remove_inventory_entry(slot_data, index, slot_data.quantity)
		inventory_updated.emit(self)
		return slot_data
	else:
		return null

# Drop or switch the currently grabbed slot with the given slot index
func drop_slot_data(grabbed_slot_data: SlotData, index: int) -> SlotData:
	var slot_data: SlotData = slot_datas[index]
	
	var return_slot_data: SlotData
	if slot_data and slot_data.can_fully_merge_with(grabbed_slot_data):
		slot_data.fully_merge_with(grabbed_slot_data)
		add_inventory_entry(slot_data, index)
		var grabbed_quantity = grabbed_slot_data.quantity
	else:
		slot_datas[index] = grabbed_slot_data
		return_slot_data = slot_data
		add_inventory_entry(grabbed_slot_data, index)
	
	inventory_updated.emit(self)
	return return_slot_data

# Drop one item into a slot
func drop_single_slot_data(grabbed_slot_data: SlotData, index: int) -> SlotData:
	var slot_data: SlotData = slot_datas[index]
	
	if not slot_data:
		slot_datas[index] = grabbed_slot_data.create_single_slot_data()
		# remove one from grabbed data
		add_inventory_entry(slot_datas[index], index)
	elif slot_data.can_merge_with(grabbed_slot_data):
		var new_slot_data = grabbed_slot_data.create_single_slot_data()
		slot_data.fully_merge_with(new_slot_data)
		add_inventory_entry(new_slot_data, index)
		
	inventory_updated.emit(self)
	
	if grabbed_slot_data.quantity > 0:
		return grabbed_slot_data
	else:
		return null

# Activate a slot data's use function (if it has one)
func use_slot_data(index: int) -> void:
	var slot_data: SlotData = slot_datas[index]
	
	if not slot_data:
		return
	
	if slot_data.item_data is ItemDataConsumable:
		slot_data.quantity -= 1
		if slot_data.quantity < 1:
			slot_datas[index] = null
	
	PlayerManager.use_slot_data(slot_data)
	
	# Remove one of the item from the inventory
	remove_inventory_entry(slot_data, index, 1)
	
	inventory_updated.emit(self)

# Pick up slot data from the world
func pick_up_slot_data(slot_data: SlotData) -> bool:
	
	for index in slot_datas.size():
		if slot_datas[index] and slot_datas[index].can_fully_merge_with(slot_data):
			slot_datas[index].fully_merge_with(slot_data)
			add_inventory_entry(slot_data, index)
			inventory_updated.emit(self)
			return true
		elif slot_datas[index] and slot_datas[index].can_partially_merge_with(slot_data):
			slot_datas[index].partially_merge_with()
			add_inventory_entry(slot_data, index)
			inventory_updated.emit(self)
			return true
			
	for index in slot_datas.size():
		if not slot_datas[index]:
			slot_datas[index] = slot_data
			add_inventory_entry(slot_data, index)
			inventory_updated.emit(self)
			return true
			
	print("Inventory is full!")
	return false

func reduce_slot_amount(index: int, amount: int) -> void:
	var slot_data: SlotData = slot_datas[index]
	if slot_data:
		slot_data.quantity -= amount
		if slot_data and slot_data.quantity < 1:
			slot_datas[index] = null
		
	inventory_updated.emit(self)

# Remove all items up to a given quantity and return remainder not removed
func remove_up_to(material: ItemData, quantity: int) -> int:
	var to_remove: int = quantity
	var inventory_items: Array[SlotData] = slot_datas
	for index in inventory_items.size():
		var slot: SlotData = inventory_items[index]
		if slot and slot.item_data == material:
			var available_quantity: int = slot.quantity
			if available_quantity >= to_remove:
				# remove quantity from item slot
				reduce_slot_amount(index, to_remove)
				to_remove = 0
				return to_remove
			else:
				reduce_slot_amount(index, available_quantity)
				to_remove -= available_quantity
	if to_remove == quantity:
		print("There are no leaves to compost!")
	return to_remove

# Check if there is enough materials available
func check_materials(material: ItemData, quantity: int) -> Dictionary:
	# Keeps track of the materials, inventory index, and missing amount
	var materials: Dictionary = { material: 
			{ 
			"missing": 0, 
			"required": quantity, 
			"inv_slots": [] 
			}
		}
	var inventory_items: Array[SlotData] = slot_datas
	var remaining_quantity: int = quantity

	# Check each inventory slot for the material, adding info to dictionary
	for index in inventory_items.size():
		var slot: SlotData = inventory_items[index]
		if slot and slot.item_data == material:
			var available_quantity: int = slot.quantity
			if available_quantity >= remaining_quantity:
				remaining_quantity = 0
				materials[material]["inv_slots"].append(index)
				break
			else:
				materials[material]["inv_slots"].append(index)
				remaining_quantity -= available_quantity
	materials[material]["missing"] = remaining_quantity
	return materials

func remove_checked_items(materials: Dictionary) -> void:
	#var materials = check_total_materials(material, quantity)
	for material: ItemData in materials.keys():
		var inventory_items: Array = slot_datas
		var required_quantity: int = materials[material]["required"] as int
		# Current amount found
		var current_quantity: int = required_quantity
		for inv_slot: int in materials[material]["inv_slots"]:
			var slot: SlotData = inventory_items[inv_slot]
			if slot and slot.quantity <= current_quantity:
				current_quantity = current_quantity - slot.quantity
				reduce_slot_amount(inv_slot, slot.quantity)
			else:
				reduce_slot_amount(inv_slot, current_quantity)

func on_slot_clicked(index: int, button: int) -> void:
	inventory_interact.emit(self, index, button)
