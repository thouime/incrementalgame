extends InventoryData

class_name InventoryDataEquip

func drop_slot_data(grabbed_slot_data: SlotData, index: int) -> SlotData:
	
	var grabbed_item : ItemData = grabbed_slot_data.item_data
	
	if not grabbed_item is ItemDataEquip:
		return grabbed_slot_data
	
	if not is_valid_type(grabbed_item, index):
		return grabbed_slot_data
	
	return super.drop_slot_data(grabbed_slot_data, index)
	
func drop_single_slot_data(grabbed_slot_data: SlotData, index: int) -> SlotData:
	
	var grabbed_item : ItemData = grabbed_slot_data.item_data
	
	if not grabbed_item is ItemDataEquip:
		return grabbed_slot_data
	
	if not is_valid_type(grabbed_item, index):
		return grabbed_slot_data
	
	return super.drop_single_slot_data(grabbed_slot_data, index)

func is_valid_type(grabbed_item: ItemData, index: int) -> bool:
	
	var equipment_type : int
	if grabbed_item:
		equipment_type = grabbed_item.equipment_type
		
	var equipment_slots: Array[PanelContainer] = get_inventory_containers()
	var clicked_slot : PanelContainer = equipment_slots[index]
	
	return equipment_type == clicked_slot.slot_type
	
func get_equips() -> Dictionary:
	var equipment_array : Array = get_inventory_slots()
	var equipment_dict := {}
	
	for slot_data: SlotData in equipment_array:
		if not slot_data:
			continue
		var equip : ItemData = slot_data.item_data
		# Set the dictionary key to the name of the enum value
		equipment_dict[equip.EquipType.find_key(equip.equipment_type)] = equip
		
	
	return equipment_dict
