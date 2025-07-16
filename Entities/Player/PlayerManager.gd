extends Node

var player: CharacterBody2D
var player_inventory: InventoryData
var player_equipment: InventoryDataEquip
var state_machine : Node
var player_state : State
var time_played : float

func use_slot_data(slot_data: SlotData) -> void:
	slot_data.item_data.use(player)

func get_global_position() -> Vector2:
	return player.global_position
