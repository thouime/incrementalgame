extends "object.gd"

@export var inventory_data: InventoryData

signal toggle_inventory(external_inventory_owner)

func _ready() -> void:
	super._ready()
	add_to_group("external_inventory")

func interact_action(player: CharacterBody2D) -> void:
	toggle_inventory.emit(self)

func player_interact() -> void:
	toggle_inventory.emit(self)

func stop_interact_action(player: CharacterBody2D) -> void:
	pass
