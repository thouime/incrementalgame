extends Node
class_name dungeon

var dungeon_data: DungeonResource:
	
	set(value):
		dungeon_data = value

func _ready() -> void:
	
	print("Dungeon is ready!")

func spawn_enemies() -> void:
	
	if not dungeon_data:
		printerr("Warning: Dungeon Scene not set on: ", dungeon_data.name)
		return
	
	var enemy_types = dungeon_data.enemy_types
	if not enemy_types.size() > 0:
		printerr("Warning: No Enemy scenes set on: ", dungeon_data.name)
	
	# Instantiate enemy scenes using marker nodes in a dungeon
	var enemy_scene = enemy_types[0]
	var enemy_spawns = get_node("EnemySpawns")
	create_enemies(enemy_scene, enemy_spawns)
	

func create_enemies(enemy_scene: PackedScene, spawns: Node2D):
	
	if not spawns:
		printerr("No enemy marker spawns found in ", dungeon_data.name)
		
	for child in spawns.get_children():
		
		if child is not Marker2D:
			continue
		
		var enemy = enemy_scene.instantiate()
		enemy.position = child.position
		
		# If the enemy has a patrol points Node, setup wandering
		if child.has_node("PatrolPoints"):
			var patrol_group = child.get_node("PatrolPoints")
			set_wander(enemy, patrol_group)
			
		add_child(enemy)

func set_wander(enemy: Node2D, patrol_group : Node2D) -> void:
	var patrol_points : Array = []
	
	for patrol_point in patrol_group.get_children():
		patrol_points.append(patrol_point.position)
	
	enemy.positions = patrol_points
