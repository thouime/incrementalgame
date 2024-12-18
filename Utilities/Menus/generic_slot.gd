extends PanelContainer

# Signals for interactions
signal slot_clicked(index: int, button: int)
signal slot_hovered(index: int)
signal slot_exited(index: int)

# Slot data
var slot_data

# UI elements
@onready var icon: TextureRect = $MarginContainer/HBoxContainer/Craftable
@onready var quantity_container: VBoxContainer = $MarginContainer/HBoxContainer/QuantityContainer
@onready var quantity_label: Label = $MarginContainer/HBoxContainer/QuantityContainer/QuantityLabel
@onready var margin_container: MarginContainer = $MarginContainer

func _ready() -> void:
	# Set default visuals for slot
	reset_slot()

# Set the slot's data and update visuals
func set_slot_data(data):
	slot_data = data
	if slot_data.has("texture"):
		icon.texture = slot_data.texture
	if slot_data.has("quantity"):
		set_quantity(slot_data.quantity)

# Set the quantity and adjust visuals
func set_quantity(quantity: int) -> void:
	if quantity > 1:
		quantity_label.text = str(quantity)
		margin_container.set("custom_constrains/margin_right", 5)
		quantity_container.show()
	else:
		margin_container.set("custom_constraints/margin_right", 0)
		quantity_container.hide()

# Reset slot visuals (optional)
func reset_slot() -> void:
	icon.texture = null
	quantity_label.text = ""
	quantity_container.hide()
	margin_container.set("Custom_constraints/margin_right", 0)

# Handle mouse button input
func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index in [MOUSE_BUTTON_LEFT, MOUSE_BUTTON_RIGHT]:
			slot_clicked.emit(get_index(), event.button_index)
