extends Node

var player: CharacterBody2D
var player_inventory: InventoryData


func use_slot_data(slot_data: SlotData) -> void:
	slot_data.item_data.use(player)

func get_global_position() -> Vector2:
	return player.global_position

func get_player_state() -> int:
	return player.state
	
func set_player_state(new_state: int) -> void:
	if player:
		player.state = new_state
