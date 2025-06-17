extends Node

var current_dungeon : Dungeon
var dungeon_data : DungeonResource

func set_dungeon(dungeon: Dungeon, dungeon_data: DungeonResource) -> void:
	current_dungeon = dungeon
	dungeon_data = dungeon_data

func get_dungeon() -> Dungeon:
	if current_dungeon:
		return current_dungeon
	else:
		printerr("No Dungeon is set in the DungeonManager!")
		return null

func get_dungeon_data() -> DungeonResource:
	if dungeon_data:
		return dungeon_data
	else:
		printerr("No Dungeon Data is set in the DungeonManager!")
		return null
