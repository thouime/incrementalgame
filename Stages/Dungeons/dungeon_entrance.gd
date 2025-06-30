extends "res://Entities/Objects/object.gd"

signal enter_dungeon(dungeon_data: DungeonResource)

@export var dungeon_data : DungeonResource

func _ready() -> void:
	super._ready()
	set_object_name("dungeon")

func interact_action(_player: CharacterBody2D) -> void:
	if dungeon_data:
		dungeon_data.enemy_count = get_enemy_count(dungeon_data)
		enter_dungeon.emit(dungeon_data)
	else:
		printerr("Warning Dungeon data not set on ", self.name)
	
	# possible loading menu

func get_enemy_count(dungeon_resource: DungeonResource) -> int:
	var dungeon_scene : PackedScene = dungeon_resource.dungeon_scene
	if not dungeon_scene:
		printerr("Warning Dungeon Scene not set on ", self.name)
	
	var dungeon : Dungeon = dungeon_scene.instantiate()
	
	var count := 0
	var enemy_spawns : Node2D = dungeon.get_node("EnemySpawns")
	if enemy_spawns:
		for child: Variant in enemy_spawns.get_children():
			if child is Marker2D:
				if not child.visible:
					continue
				count += 1
	
	dungeon.queue_free()
	return count

func stop_interact_action(_player: CharacterBody2D) -> void:
	pass
