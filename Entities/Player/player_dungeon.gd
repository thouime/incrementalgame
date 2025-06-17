class_name PlayerDungeon
extends State

# This state handles the player dungeon logic
# The player will automatically explore the dungeon
# The player can exit by clicking exit, dying, or completing dungeon

var is_chasing : bool
var is_attacking : bool
var dungeon_goal_tiles : Array[Vector2]
var current_goal_tile : Vector2

func enter() -> void:
	# Get dungeon goal tiles, pick one randomly
	set_dungeon_goal()

func exit() -> void:
	is_chasing = false
	is_attacking = false
	dungeon_goal_tiles = []
	current_goal_tile = Vector2.ZERO

func process_input(event: InputEvent) -> State:

	return null
	
func process_physics(_delta: float) -> State:
	
	var player_position := parent.global_position
	var closest_enemy : Enemy = get_nearest_enemy()
	var chase_range : float = parent.chase_range
	
	# pathfind to tile
	var target_position : Vector2 = current_goal_tile

	# Chase enemies
	if not is_attacking:
		if player_position.distance_to(closest_enemy.position) < chase_range:
			is_chasing = true
			target_position = closest_enemy.global_position
			print("Chasing enemy...")

	# If player is close enough to enemy, start attacking
	if is_chasing:
		if target_in_range(closest_enemy, parent.attack_range):
			target_position = Vector2.ZERO
			is_chasing = false
			is_attacking = true
	
	parent.nav_agent.target_position = target_position
	
	var next_point = parent.nav_agent.get_next_path_position()
	var direction = (next_point - parent.global_position).normalized()
	var movement_velocity = direction * parent.player_speed
	
	parent.velocity = movement_velocity
	update_animation()
	
	parent.move_and_slide()
	
	return null

func process_frame(_delta: float) -> State:

	return null

func death() -> void:
	# reset player health
	# teleport outside of dungeon
	pass

func complete_dungeon() -> void:
	# leave dungeon
	# start over
	# option to automatically start over
	pass

# Randomly set the goal of the destination tile
func set_dungeon_goal() -> void:
	var dungeon : Dungeon = DungeonManager.get_dungeon()
	var goal_tiles : Node2D = dungeon.get_node("GoalTiles")
	if not goal_tiles:
		printerr("There is no Goal Tiles node!")
		return
	for goal_tile : Marker2D in goal_tiles.get_children():
		dungeon_goal_tiles.append(goal_tile.position)
	
	current_goal_tile = dungeon_goal_tiles.pick_random()

func get_nearest_enemy() -> Enemy:
	
	var nearest_enemy: Enemy = null
	var nearest_distance = INF
	var player_position = parent.global_position
	
	for enemy in get_tree().get_nodes_in_group("enemy"):
		# Ensure instance is valid and wasn't deleted from memory
		if not is_instance_valid(enemy):
			continue
		var dist = player_position.distance_squared_to(enemy.global_position)
		if dist < nearest_distance:
			nearest_distance = dist
			nearest_enemy = enemy
	
	return nearest_enemy

func update_animation():
	var dir = parent.velocity.normalized()
	var animation_prefix : String = "walk"
	
	if is_attacking:
		animation_prefix = "attack"
	
	parent.animated_sprite.flip_h = false
	
	if abs(dir.x) > abs(dir.y):
		
		parent.animated_sprite.play(animation_prefix + "_right")
		parent.animated_sprite.flip_h = dir.x < 0
	
	else:
		if dir.y > 0:
			parent.animated_sprite.play(animation_prefix + "_down")
		else:
			parent.animated_sprite.play(animation_prefix + "_up")
			
func target_in_range(target: Enemy, distance: float) -> bool:

	var target_position = target.position
	
	if parent.global_position.distance_to(target_position) <= distance:
		return true
		
	return false
