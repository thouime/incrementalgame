extends Node

var crafting_menu : PanelContainer

func connect_signals() -> void:
	crafting_menu.craft_item_request.connect(CraftingSystem.try_craft)
