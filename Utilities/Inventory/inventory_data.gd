extends Resource
class_name InventoryData

@export var slot_datas: Array[SlotData]

signal inventory_interact(inventory_data: InventoryData, index: int, button: int)
signal inventory_updated(inventory_data: InventoryData)

func grab_slot_data(index: int) -> SlotData:
	var slot_data: SlotData = slot_datas[index]
	
	if slot_data:
		slot_datas[index] = null
		inventory_updated.emit(self)
		return slot_data
	else:
		return null

func drop_slot_data(grabbed_slot_data: SlotData, index: int) -> SlotData:
	var slot_data: SlotData = slot_datas[index]
	
	var return_slot_data: SlotData
	if slot_data and slot_data.can_fully_merge_with(grabbed_slot_data):
		slot_data.fully_merge_with(grabbed_slot_data)
	else:
		slot_datas[index] = grabbed_slot_data
		return_slot_data = slot_data
	
	inventory_updated.emit(self)
	return return_slot_data

func drop_single_slot_data(grabbed_slot_data: SlotData, index: int) -> SlotData:
	var slot_data: SlotData = slot_datas[index]
	
	if not slot_data:
		slot_datas[index] = grabbed_slot_data.create_single_slot_data()
	elif slot_data.can_merge_with(grabbed_slot_data):
		slot_data.fully_merge_with(grabbed_slot_data.create_single_slot_data())
		
	inventory_updated.emit(self)
	
	if grabbed_slot_data.quantity > 0:
		return grabbed_slot_data
	else:
		return null

func use_slot_data(index: int) -> void:
	var slot_data: SlotData = slot_datas[index]
	
	if not slot_data:
		return
	
	if slot_data.item_data is ItemDataConsumable:
		slot_data.quantity -= 1
		if slot_data.quantity < 1:
			slot_datas[index] = null
	
	print(slot_data.item_data.name)
	PlayerManager.use_slot_data(slot_data)
	
	inventory_updated.emit(self)

func pick_up_slot_data(slot_data: SlotData) -> bool:
	
	for index in slot_datas.size():
		if slot_datas[index] and slot_datas[index].can_fully_merge_with(slot_data):
			slot_datas[index].fully_merge_with(slot_data)
			inventory_updated.emit(self)
			return true
		elif slot_datas[index] and slot_datas[index].can_partially_merge_with(slot_data):
			slot_datas[index].partially_merge_with()
			inventory_updated.emit(self)
			return true
			
	for index in slot_datas.size():
		if not slot_datas[index]:
			slot_datas[index] = slot_data
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
