extends PanelContainer

# Let the state machine know that it can enter the building state
signal craft_request

const Slot = preload("res://Utilities/Crafting/crafting_slot.tscn")

# Small interface element that displays info about each craftable
const CRAFT_INFO = preload("res://Utilities/Crafting/craft_info.tscn")

# All the crafting slots in the menu
@export var craft_slots: Array[CraftData]

# Flag to check if mouse is hovering over Craftables for more info
var craft_hovering: bool = false

@onready var canvas_layer: CanvasLayer = $CanvasLayer
@onready var crafting_grid: GridContainer = $MarginContainer/CraftingGrid

func _ready() -> void:
	populate_crafting_grid()
	
# Create the crafting grid for each craftable item
func populate_crafting_grid() -> void:
	for craft_slot in craft_slots:
		var slot: PanelContainer = Slot.instantiate()
		crafting_grid.add_child(slot)
		if craft_slot:
			slot.set_craft_data(craft_slot)
			add_info(craft_slot)
		slot.craft_slot_clicked.connect(self.on_slot_clicked)
		slot.craft_slot_hovered.connect(self.on_slot_hovered)
		slot.craft_slot_exited.connect(self.on_slot_exited)

func add_info(craft_data: CraftData) -> void:
	# Create info interface that shows each type of material required
	var craft_info: PanelContainer = CRAFT_INFO.instantiate()
	canvas_layer.add_child(craft_info)
	craft_info.set_info(craft_data)
	
	var materials: Array = craft_data.material_slot_datas
	for craft_material: MaterialSlotData in materials:
		if not craft_material:
			return
		craft_info.add_material(
			craft_material.item_data, 
			craft_material.quantity
		)
		
	# Position craft_info window above crafting interface
	set_info_pos(craft_info)

func set_info_pos(craft_info: Control) -> void:
	var menu_position: Vector2 = self.global_position
	var padding: int = 10
	var new_pos: float = craft_info.get_combined_minimum_size().y + padding
	craft_info.global_position = menu_position - Vector2(0, new_pos)

func show_craft_info(craft_slot: int) -> void:
	if not craft_hovering:
		craft_hovering = true
		var craft_info: PanelContainer = canvas_layer.get_child(craft_slot)
		if craft_info:
			craft_info.show()
	
func hide_craft_info(craft_slot: int) -> void:
	if craft_hovering:
		craft_hovering = false
		var craft_info: PanelContainer = canvas_layer.get_child(craft_slot)
		if craft_info:
			craft_info.hide()
			
func on_slot_clicked(craft_slot: int, _button: int) -> void:
	craft_request.emit(craft_slots[craft_slot])

func on_slot_hovered(index: int) -> void:
	show_craft_info(index)

func on_slot_exited(index: int) -> void:
	hide_craft_info(index)
