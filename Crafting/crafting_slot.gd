extends PanelContainer

@onready var craftable: TextureRect = $MarginContainer/HBoxContainer/Craftable
@onready var quantity_container: VBoxContainer = $MarginContainer/HBoxContainer/QuantityContainer
@onready var quantity_label: Label = $MarginContainer/HBoxContainer/QuantityContainer/QuantityLabel
@onready var margin_container: MarginContainer = $MarginContainer

signal craft_slot_clicked(index: int, button: int)
signal craft_slot_hovered(index: int)
signal craft_slot_exited(index: int)

func set_craft_data(craft_data: CraftData) -> void:
	craftable.texture = craft_data.menu_texture

func set_quantity(quantity: int) -> void:
	if quantity > 1:
		quantity_label.text = str(quantity)
		margin_container.set("custom_constraints/margin_right", 5)
		quantity_container.show()
	else:
		margin_container.set("custom_constraints/margin_right", 0)
		quantity_container.hide()
		
func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index in [MOUSE_BUTTON_LEFT, MOUSE_BUTTON_RIGHT]:
			craft_slot_clicked.emit(get_index(), event.button_index)

# Checking if mouse hovers to show crafting information
func _on_mouse_entered() -> void:
	modulate = Color(1, 1, 1, 0.3)
	craft_slot_hovered.emit(get_index())
	
func _on_mouse_exited() -> void:
	modulate = Color(1, 1, 1, 1)
	craft_slot_exited.emit(get_index())
