extends Control

const COLLECTION_SLOT = preload("res://Utilities/Menus/Collection/collection_slot.tscn")

@export var collection_list : Array[CollectionSlotData]
@onready var h_flow_container: HFlowContainer = $HFlowContainer

func _ready() -> void:
	for collectable : CollectionSlotData in collection_list:
		if not collectable:
			continue
		var new_collectable: PanelContainer = COLLECTION_SLOT.instantiate()
		h_flow_container.add_child(new_collectable)
		new_collectable.set_item(collectable.item, collectable.attack_bonus)
		collectable.collection_slot = new_collectable
	
	print("Collection Menu Loaded!")
