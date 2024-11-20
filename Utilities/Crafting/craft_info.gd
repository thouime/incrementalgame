extends PanelContainer

@onready var v_box_container: VBoxContainer = $VBoxContainer
@onready var craft_name: Label = $VBoxContainer/CraftName

const MATERIAL_INFO = preload("res://Utilities/Crafting/material_info.tscn")

func set_info(craft: CraftData) -> void:
	craft_name.text = craft.name

func add_material(item: ItemData, quantity: int) -> void:
	# Instance the material info scene
	var material_info: HBoxContainer = MATERIAL_INFO.instantiate()
	if material_info:
		v_box_container.add_child(material_info)
		material_info.set_info(item.texture, item.name, quantity)
	else:
		print("Failed to instantiate material info")
