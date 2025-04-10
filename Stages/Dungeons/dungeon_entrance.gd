extends "res://Entities/Objects/object.gd"

@export var dungeon_data : DungeonResource

func _ready() -> void:
	super._ready()
	set_object_name("dungeon")

func interact_action(_player: CharacterBody2D) -> void:
	show_dungeon_info()

func show_dungeon_info() -> void:
	if dungeon_data:
		print("Dungeon: ", dungeon_data.dungeon_name)
		print("Difficulty: ", dungeon_data.difficulty)
		print("Enemy Count: ", dungeon_data.enemy_count)
		print("Estimated Completion: ", dungeon_data.estimated_completion)
		print("Completions: ", dungeon_data.completions)
		print("Loot Table: ", dungeon_data.loot_table)

func stop_interact_action(_player: CharacterBody2D) -> void:
	pass
