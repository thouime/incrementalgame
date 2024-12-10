extends Node

@onready var crafting_system: Node = $CraftingSystem
@onready var crafting_menu: PanelContainer = $"../UI/CraftingMenu"

func _ready() -> void:
	crafting_menu.craft_item_request.connect(crafting_system.try_craft)
