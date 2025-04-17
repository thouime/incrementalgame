extends "res://Entities/Objects/object.gd"

signal enter_dungeon(dungeon_data: DungeonResource)

@export var dungeon_data : DungeonResource

func _ready() -> void:
	super._ready()
	set_object_name("dungeon")

func interact_action(_player: CharacterBody2D) -> void:
	if dungeon_data:
		show_dungeon_info()
		enter_dungeon.emit(dungeon_data)
	else:
		printerr("Warning Dungeon data not set on ", self.name)
	
	# possible loading menu

func show_dungeon_info() -> void:
	print("Dungeon: ", dungeon_data.name)
	print("Difficulty: ", dungeon_data.difficulty)
	print("Enemy Count: ", dungeon_data.enemy_count)
	print("Estimated Completion: ", dungeon_data.estimated_completion)
	print("Completions: ", dungeon_data.completions)
	print("Loot Table: ", dungeon_data.loot_table)

func stop_interact_action(_player: CharacterBody2D) -> void:
	pass
