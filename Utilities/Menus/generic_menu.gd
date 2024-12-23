extends PanelContainer

signal slot_clicked

const SLOT = preload("res://Utilities/Menus/generic_slot.tscn")
const SLOT_INFO = preload("res://Utilities/Menus/slot_info.tscn")

# All the different buildable tiles
@export var slot_datas : Array[Resource]

# Flag to check if mouse is hovering over Slots for more info
var slot_hovering: bool = false
 
@onready var canvas_layer: CanvasLayer = $CanvasLayer
@onready var slot_grid: GridContainer = $MarginContainer/SlotGrid

func _ready() -> void:
	populate_slot_grid()

# Create the slot grid for each slot shown in the menu
func populate_slot_grid() -> void:
	for slot_data in slot_datas:
		var slot: PanelContainer = SLOT.instantiate()
		slot_grid.add_child(slot)
		if slot:
			slot.set_slot_info(slot_data)
			add_info(slot_data)
		slot.slot_clicked.connect(self.on_slot_clicked)
		slot.slot_hovered.connect(self.on_slot_hovered)
		slot.slot_exited.connect(self.on_slot_exited)

# Create info interface that shows extra information
func add_info(slot_data: Resource) -> void:
	# Create info interface that shows each type of material required
	var slot_info: PanelContainer = SLOT_INFO.instantiate()
	canvas_layer.add_child(slot_info)
	slot_info.set_info(slot_data)
	set_info_pos(slot_info)

func set_info_pos(slot_info: Control) -> void:
	var menu_position: Vector2 = self.global_position
	var padding: int = 10
	var new_pos: float = slot_info.get_combined_minimum_size().y + padding
	slot_info.global_position = menu_position - Vector2(0, new_pos)

func show_slot_info(slot_index: int) -> void:
	if not slot_hovering:
		slot_hovering = true
		var slot_info: PanelContainer = canvas_layer.get_child(slot_index)
		if slot_info:
			slot_info.show()
	
func hide_slot_info(slot_index: int) -> void:
	if slot_hovering:
		slot_hovering = false
		var slot_info: PanelContainer = canvas_layer.get_child(slot_index)
		if slot_info:
			slot_info.hide()

func on_slot_clicked(index: int, _button: int) -> void:
	print("Generic Slot Clicked!")
	slot_clicked.emit(slot_datas[index])

func on_slot_hovered(index: int) -> void:
	show_slot_info(index)

func on_slot_exited(index: int) -> void:
	hide_slot_info(index)
	
