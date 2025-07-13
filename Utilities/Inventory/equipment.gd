extends PanelContainer

const Slot = preload("res://Utilities/Inventory/slot.tscn")

var equipment_slots: Array[PanelContainer] = []

@onready var axe_slot: PanelContainer = $MarginContainer/VBoxContainer/SkillSlots/AxeSlot
@onready var pickaxe_slot: PanelContainer = $MarginContainer/VBoxContainer/SkillSlots/PickaxeSlot
@onready var armor_slot: PanelContainer = $MarginContainer/VBoxContainer/ArmorSlots/ArmorSlot
@onready var armor_slot_2: PanelContainer = $MarginContainer/VBoxContainer/ArmorSlots/ArmorSlot2
@onready var armor_slot_3: PanelContainer = $MarginContainer/VBoxContainer/ArmorSlots/ArmorSlot3
@onready var armor_slot_4: PanelContainer = $MarginContainer/VBoxContainer/ArmorSlots/ArmorSlot4
@onready var armor_slot_5: PanelContainer = $MarginContainer/VBoxContainer/ArmorSlots/ArmorSlot5

func set_inventory_data(inventory_data: InventoryData) -> void:
	if not inventory_data.inventory_updated.is_connected(populate_equipment):
		inventory_data.inventory_updated.connect(populate_equipment)
	
	connect_slots(inventory_data)
	populate_equipment(inventory_data)
	inventory_data.set_inventory_containers(equipment_slots)

func clear_inventory_data(inventory_data: InventoryData) -> void:
	inventory_data.inventory_updated.disconnect(populate_equipment)

func connect_slots(inventory_data: InventoryData) -> void:
	equipment_slots = [
		axe_slot,
		pickaxe_slot,
		armor_slot,
		armor_slot_2,
		armor_slot_3,
		armor_slot_4,
		armor_slot_5
	]
	var slot_index : int = 0
	for slot in equipment_slots:
		slot.slot_index = slot_index
		slot_index += 1
		if not slot.slot_clicked.is_connected(inventory_data.on_slot_clicked):
			slot.slot_clicked.connect(inventory_data.on_slot_clicked)

func populate_equipment(inventory_data: InventoryData) -> void:

	for i in equipment_slots.size():
		var slot : PanelContainer = equipment_slots[i]
		var slot_data: SlotData = inventory_data.slot_datas[i]
		
		slot.clear_slot()
		slot.set_bg_texture()
		
		if slot_data:
			slot.set_slot_data(slot_data)
	
