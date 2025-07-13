extends InventoryData

class_name InventoryDataEquip

func drop_slot_data(grabbed_slot_data: SlotData, index: int) -> SlotData:
	
	var grabbed_item : ItemData = grabbed_slot_data.item_data
	var equipment_type : int
	
	if grabbed_item:
		equipment_type = grabbed_item.equipment_type
		
	var equipment_slots: Array[PanelContainer] = get_inventory_containers()
	var clicked_slot : PanelContainer = equipment_slots[index]
	
	if not grabbed_item is ItemDataEquip:
		return grabbed_slot_data
	
	if not equipment_type == clicked_slot.slot_type:
		return grabbed_slot_data
	
	return super.drop_slot_data(grabbed_slot_data, index)
	
func drop_single_slot_data(grabbed_slot_data: SlotData, index: int) -> SlotData:
	
	if not grabbed_slot_data.item_data is ItemDataEquip:
		return grabbed_slot_data
	
	return super.drop_single_slot_data(grabbed_slot_data, index)
