extends PanelContainer

const Slot = preload("res://Utilities/Inventory/slot.tscn")
@onready var item_grid: GridContainer = $MarginContainer/ItemGrid

func set_inventory_data(inventory_data: InventoryData) -> void:
	if not inventory_data.inventory_updated.is_connected(populate_item_grid):
		inventory_data.inventory_updated.connect(populate_item_grid)

	populate_item_grid(inventory_data)

func clear_inventory_data(inventory_data: InventoryData) -> void:
	inventory_data.inventory_updated.disconnect(populate_item_grid)

func populate_item_grid(inventory_data: InventoryData) -> void:
	for child in item_grid.get_children():
		child.queue_free()
	
	var slot_index: int = 0
	for slot_data in inventory_data.slot_datas:
		var slot: PanelContainer = Slot.instantiate()
		item_grid.add_child(slot)
		slot.slot_index = slot_index
		slot_index += 1

		slot.slot_clicked.connect(inventory_data.on_slot_clicked)
		
		if slot_data:
			slot.set_slot_data(slot_data)
