extends Resource
class_name InventoryData

@export var slot_datas: Array[SlotData]

signal inventory_interact(inventory_data: InventoryData, index: int, button: int)
signal inventory_updated(inventory_data: InventoryData)

func grab_slot_data(index: int) -> SlotData:
	var slot_data = slot_datas[index]
	
	if slot_data:
		slot_datas[index] = null
		inventory_updated.emit(self)
		return slot_data
	else:
		return null

func drop_slot_data(grabbed_slot_data: SlotData, index: int) -> SlotData:
	var slot_data = slot_datas[index]
	
	var return_slot_data: SlotData
	if slot_data and slot_data.can_fully_merge_with(grabbed_slot_data):
		slot_data.fully_merge_with(grabbed_slot_data)
	else:
		slot_datas[index] = grabbed_slot_data
		return_slot_data = slot_data
	
	inventory_updated.emit(self)
	return return_slot_data

func drop_single_slot_data(grabbed_slot_data: SlotData, index: int) -> SlotData:
	var slot_data = slot_datas[index]
	
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
	var slot_data = slot_datas[index]
	
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

func is_inventory_full(slot_data: SlotData) -> bool:
	return false

func reduce_slot_amount(index: int, amount: int) -> void:
	var slot_data = slot_datas[index]
	if slot_data:
		slot_data.quantity -= amount
		if slot_data and slot_data.quantity < 1:
			slot_datas[index] = null
		
	inventory_updated.emit(self)

# Check if there is enough materials available
# Otherwise return an empty list
func check_total_materials(material: ItemData, quantity: int) -> Array:
	# List of materials to be removed from inventory
	var materials = []
	var inventory_items = slot_datas
	# Total amount needed
	var required_quantity = quantity
	# Current amount found
	var quantity_needed = required_quantity
	for index in inventory_items.size():
		var slot = inventory_items[index]
		if slot and slot.item_data == material:
			# Quantity of current item
			var available_quantity = slot.quantity
			# There's enough in the slot
			if available_quantity >= required_quantity:
				quantity_needed = 0
				materials.append(index)
				break
			# If there's not enough in the slot, subtract what's available
			# and continue to the next item
			else:
				quantity_needed -= available_quantity
				materials.append(index)
				continue
	if quantity_needed == 0:
		print("There is enough ", material.name, "s for crafting!")
		return materials
	else:
		return []

func reduce_slot_datas(materials: Dictionary) -> void:
	#var materials = check_total_materials(material, quantity)
	for material in materials.keys():
		var inventory_items = slot_datas
		var required_quantity = material.quantity
		# Current amount found
		var current_quantity = required_quantity
		for index in materials[material]["slots"]:
			var slot = inventory_items[index]
			if slot and slot.quantity <= current_quantity:
				current_quantity = current_quantity - slot.quantity
				reduce_slot_amount(index, slot.quantity)
			else:
				reduce_slot_amount(index, current_quantity)
				
func on_slot_clicked(index: int, button: int) -> void:
	inventory_interact.emit(self, index, button)
