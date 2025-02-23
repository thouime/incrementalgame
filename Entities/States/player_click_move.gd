class_name PlayerClickMove
extends State

@export var idle_state : State
@export var gather_state : State
@export var build_state : State
@export var key_move_state : State
# An array of each tile using Astar pathfinding
var tile_path : Array = []
# Keep track of the target tile in a tile path array
var current_target_index : int = 0
var ready_to_build : bool = false

func enter() -> void:
	pass

func exit() -> void:
	parent.velocity = Vector2.ZERO
	parent.target_position = Vector2.ZERO
	tile_path = []
	current_target_index = 0
	ready_to_build = false

func process_input(_event: InputEvent) -> State:
	# Allow interruption to key movement
	for action : String in directions.keys():
		if Input.is_action_just_pressed(action):
			return key_move_state
	return null
	
func process_physics(delta: float) -> State:
	var velocity : Vector2  = move_towards_target(delta, parent.target_position)
	parent.animated_sprite.animation = animations[parent.direction]
	
	# Flip the sprite if facing left
	if velocity.x != 0:
		parent.animated_sprite.flip_h = velocity.x < 0
		
	# Start movement
	velocity = velocity.normalized() * move_speed
	if parent.global_position.distance_to(parent.target_position) <= 10:
		return gather_state

	parent.position += velocity * delta
	parent.move_and_slide()
	return null

func process_frame(_delta: float) -> State:
	# Start the building operation
	if ready_to_build:
		return build_state
	
	return null

func move_towards_target(_delta: float, target_position: Vector2) -> Vector2:
	
	# Calculate a new path if there isn't one
	if tile_path.size() == 0:
		tile_path = parent.a_star_pathfinding.get_tile_path(
			parent.global_position, target_position
		)
		current_target_index = 0
	
	# If we reached the end of the tile path, stop moving
	if current_target_index >= tile_path.size():
		return Vector2.ZERO
	
	var current_target = tile_path[current_target_index]
	
	# Calculate the direction vector to the target position
	var direction : Vector2 = (
		current_target - parent.global_position
	).normalized()
	
	# Check if we reached the current target
	if parent.global_position.distance_to(current_target) <= 10:
		current_target_index += 1
		if current_target_index >= tile_path.size():
			return Vector2.ZERO
		current_target = tile_path[current_target_index]
		direction = (current_target - parent.global_position).normalized()
	
	# Get the animation direction based on which is closest to the object
	parent.direction = get_closest_direction(direction)
	# Calculate the velocity
	var velocity : Vector2 = direction * parent.player_speed
	return velocity

func get_closest_direction(direction: Vector2) -> Vector2:
	# Calculate dot products with each main direction
	var dot_right: float = direction.dot(Vector2.RIGHT)
	var dot_left: float = direction.dot(Vector2.LEFT)
	var dot_up: float = direction.dot(Vector2.UP)
	var dot_down: float = direction.dot(Vector2.DOWN)

	# Determine which direction has the highest dot product (most aligned)
	var max_dot : float = max(dot_right, dot_left, dot_up, dot_down)

	# Set default priority order for cases where directions are equally close
	if max_dot == dot_right:
		return Vector2.RIGHT
	elif max_dot == dot_left:
		return Vector2.LEFT
	elif max_dot == dot_up:
		return Vector2.UP
	else:
		return Vector2.DOWN

func _on_interact_signal(
	pos: Vector2, 
	offset: float,
	object: StaticBody2D
) -> void:
		
	# Check if they are already interacting with the same object
	if object != parent.interact_target:
		parent.interact_target = object
		parent.target_position = pos
		parent.target_position.y += offset
	
func start_building() -> void:
	ready_to_build = true
