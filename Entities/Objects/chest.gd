extends "object.gd"

@export var inventory_data: InventoryData

signal toggle_inventory(external_inventory_owner: Node)

func _ready() -> void:
	super._ready()
	set_object_type("External Inventory")
	set_object_name("chest")
	inventory_data = InventoryData.new()
	inventory_data.initialize_slots(20)
	add_to_group("external_inventory")

func interact_action(_player: CharacterBody2D) -> void:
	toggle_inventory.emit(self)

# Opening using raycast and interact key (E)
func player_interact() -> void:
	toggle_inventory.emit(self)

func stop_interact_action(_player: CharacterBody2D) -> void:
	pass
