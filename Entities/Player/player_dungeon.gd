class_name PlayerDungeon
extends State

signal exit_dungeon

@export var idle_state : State

var is_attacking := false

# This enumerator handles the player dungeon logic
# The player will automatically explore the dungeon
# The player can exit by clicking exit, dying, or completing dungeon

enum DungeonSubstate {
	EXPLORING,
	CHASING,
	ATTACKING
}

var current_substate: DungeonSubstate = DungeonSubstate.EXPLORING
var dungeon_goal_tiles : Array[Vector2]
var current_goal_tile : Vector2
var target_position : Vector2
var target_enemy : Enemy = null
# How much time before next attack
var attack_cooldown := 0.0
var dungeon_completed := false

func enter() -> void:
	current_substate = DungeonSubstate.EXPLORING
	exit_dungeon.connect(parent.main_world._on_exit_dungeon.bind(
		DungeonManager.current_dungeon)
	)
	# Get dungeon goal tiles, pick one randomly
	set_dungeon_goal()
	# Clear any interact targets from previous states
	parent.interact_target = null

func exit() -> void:
	exit_dungeon.disconnect(parent.main_world._on_exit_dungeon)
	dungeon_goal_tiles = []
	current_goal_tile = Vector2.ZERO
	DungeonManager.clear_dungeon()
	dungeon_completed = false

func process_input(_event: InputEvent) -> State:
	
	return null
	
func process_physics(delta: float) -> State:

	var player_position := parent.global_position
	var chase_range : float = parent.chase_range

	var closest_enemy : Enemy = get_nearest_enemy()
	
	# Player is dead, skip physics processing for now
	if parent.health <= 0:
		return null
	
	if dungeon_completed:
		complete_dungeon()
		return idle_state
	
	match current_substate:
		DungeonSubstate.ATTACKING:
			parent.velocity = Vector2.ZERO
			
			# Check if enemy was queued free for changing state
			if not target_enemy:
				current_substate = DungeonSubstate.EXPLORING
				return
			
			attack(delta, target_enemy)

				
		# If player is close enough to enemy, start attacking
		DungeonSubstate.CHASING:
			if target_in_range(closest_enemy, parent.attack_range):
				parent.velocity = Vector2.ZERO
				target_enemy = closest_enemy
				current_substate = DungeonSubstate.ATTACKING
			
			navigate(player_position, target_position)
			
		DungeonSubstate.EXPLORING:
			if not closest_enemy: # All enemies defeated
				target_position = current_goal_tile
			elif player_position.distance_to(closest_enemy.position) < chase_range:
				current_substate = DungeonSubstate.CHASING
				target_position = closest_enemy.global_position
			# Pathfind to a preset goal tile
			else:
				target_position = current_goal_tile
				
			navigate(player_position, target_position)
			
	parent.move_and_slide()
	
	return null

func process_frame(_delta: float) -> State:

	return null

func _on_nav_agent_velocity_computed(safe_velocity: Vector2) -> void:
	parent.velocity = safe_velocity

func attack(delta: float, attack_target: Enemy) -> void:
	
	if is_attacking:
		return
	
	var dir : Vector2
	
	if attack_cooldown > 0:
		attack_cooldown -= delta
		
		dir = get_target_dir()
		parent.animated_sprite.play("idle" + get_anim_dir(dir))
		parent.animated_sprite.flip_h = dir.x < 0
		return
	
	is_attacking = true
	
	dir = get_target_dir()
	var animation_prefix := "attack"
		
	var animation_name := animation_prefix + get_anim_dir(dir)

	parent.animated_sprite.play(animation_name)
	parent.animated_sprite.flip_h = dir.x < 0
	
	await get_tree().create_timer(
		Helper.get_animation_duration(
			parent.animated_sprite, animation_name
		) * 0.40
	).timeout
	
	if attack_target and is_instance_valid(attack_target):
		attack_target.hit(parent.get_attack_damage())

	attack_cooldown = 1.0 / parent.attack_speed
	
	is_attacking = false

# Randomly set the goal of the destination tile
func set_dungeon_goal() -> void:
	
	var dungeon : Dungeon = DungeonManager.get_dungeon()
	var goal_tiles : Node2D = dungeon.get_node("GoalTiles")
	if not goal_tiles:
		printerr("There are no goal tiles set!")
		return
	for goal_tile : Marker2D in goal_tiles.get_children():
		dungeon_goal_tiles.append(goal_tile.position)
	
	current_goal_tile = dungeon_goal_tiles.pick_random()

func get_nearest_enemy() -> Enemy:
	
	var nearest_enemy: Enemy = null
	var nearest_distance := INF
	var player_position : Vector2 = parent.global_position
	
	for enemy in get_tree().get_nodes_in_group("enemy"):
		# Ensure instance is valid and wasn't deleted from memory
		if not is_instance_valid(enemy):
			continue
		var dist := player_position.distance_squared_to(enemy.global_position)
		if dist < nearest_distance:
			nearest_distance = dist
			nearest_enemy = enemy
	
	return nearest_enemy

func update_animation() -> void:
	var dir : Vector2 = parent.velocity.normalized()
	var animation_prefix : String = "walk"
	
	if dir == Vector2.ZERO:
		animation_prefix = "idle"
	
	parent.animated_sprite.flip_h = false
	parent.animated_sprite.play(animation_prefix + get_anim_dir(dir))
	parent.animated_sprite.flip_h = dir.x < 0
	
func get_target_dir() -> Vector2:
	var dir: Vector2 = parent.velocity.normalized()
	if target_enemy and is_instance_valid(target_enemy):
		dir = (
			target_enemy.global_position - parent.global_position
		).normalized()
	return dir
	
func get_anim_dir(dir: Vector2) -> String:
	
	if abs(dir.x) > abs(dir.y):
		return "_right"
	else:
		if dir.y > 0:
			return "_down"
		else:
			return "_up"

func target_in_range(target: Enemy, distance: float) -> bool:

	target_position = target.position
	
	if parent.global_position.distance_to(target_position) <= distance:
		return true
		
	return false

func navigate(player_position: Vector2, target_pos : Vector2) -> void:
	
	parent.nav_agent.target_position = target_pos
	
	var next_point : Vector2 = parent.nav_agent.get_next_path_position()
	var direction : Vector2 = player_position.direction_to(next_point)
	var movement_velocity : Vector2 = direction * parent.player_speed
	
	# Navigation has ended
	if parent.nav_agent.is_navigation_finished():
		parent.velocity = Vector2.ZERO
		if target_pos in dungeon_goal_tiles:
			dungeon_goal_tiles.erase(current_goal_tile)
		if not dungeon_goal_tiles.is_empty():
			current_goal_tile = dungeon_goal_tiles.pick_random()
		else:
			dungeon_completed = true
		return
	
	if parent.nav_agent.avoidance_enabled:
		parent.nav_agent.set_velocity(movement_velocity)
	else:
		_on_nav_agent_velocity_computed(movement_velocity)
	
	parent.velocity = movement_velocity
	
	if current_substate != DungeonSubstate.ATTACKING:
		update_animation()

func complete_dungeon() -> void:
	print("Dungeon is completed!")
	exit_dungeon.emit()
	# start over
	# option to automatically start over
