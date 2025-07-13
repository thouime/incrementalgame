extends PanelContainer

signal slot_clicked(index: int, button: int)

const ICONS = preload("res://Entities/Item/#1 - Transparent Icons.png")

var slot_index : int = -1

@onready var texture_rect: TextureRect = $MarginContainer/TextureRect
@onready var quantity_label: Label = $QuantityLabel

enum SlotType {
	ITEM,
	ARMOR,
	AXES,
	PICKAXES
}

@export var slot_type: SlotType = SlotType.ITEM

func set_slot_data(slot_data: SlotData) -> void:

	var item_data: ItemData = slot_data.item_data

	if item_data:
		texture_rect.modulate = Color(1, 1, 1, 1)
		texture_rect.texture = item_data.texture
		tooltip_text = "%s\n%s" % [item_data.name, item_data.description]
	
	if slot_data.quantity > 1:
		quantity_label.text = "x%s" % slot_data.quantity
		quantity_label.show()
	else:
		quantity_label.hide()

func clear_slot() -> void:
	texture_rect.texture = null

func get_slot_type() -> SlotType:
	return slot_type

func set_bg_texture() -> void:

	var region := Rect2()

	match slot_type:
		SlotType.ITEM:
			return
		SlotType.ARMOR:
			region = Rect2(96, 224, 32, 32)
		SlotType.AXES:
			region = Rect2(32, 320, 32, 32)
		SlotType.PICKAXES:
			region = Rect2(64, 320, 32, 32)
	
	texture_rect.texture = get_icon_bg(region)
	texture_rect.modulate = Color(1, 1, 1, 0.25)

func get_icon_bg(region: Rect2) -> AtlasTexture:
	
	var atlas := AtlasTexture.new()
	atlas.atlas = ICONS
	atlas.region = region
	return atlas

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index in [MOUSE_BUTTON_LEFT, MOUSE_BUTTON_RIGHT]:
			slot_clicked.emit(slot_index, event.button_index)
