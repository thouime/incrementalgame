class_name PlayerClickMove
extends State

@export var idle_state : State
@export var gather_state : State
@export var build_state : State
@export var key_move_state : State

# Keep track of the target tile in a tile path array
var current_target_index : int = 0
var ready_to_build : bool = false

# Detect if the player is dragging the mouse after clicking
var is_dragging : bool = false
var cursor_position := Vector2.ZERO
var start_tile : Vector2i
var last_tile : Vector2i

# An array of each tile using Astar pathfinding
var tile_path : Array = []
var pathfinder : Node 

func enter() -> void:
	
	pathfinder = get_a_star()
	# Detect if the player is still holding left mouse button
	is_dragging = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)

func exit() -> void:
	
	clear_position()
	ready_to_build = false

func clear_position() -> void:
	
	parent.velocity = Vector2.ZERO
	parent.target_position = Vector2.ZERO
	tile_path = []
	current_target_index = 0

func process_input(event: InputEvent) -> State:

	# Allow interruption to key movement
	for action : String in directions.keys():
		if Input.is_action_just_pressed(action):
			return key_move_state
		
	# Check for new mouse inputs
	if event is InputEventMouseButton:

		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			#clear_position()
			set_target_position(cursor_position)
			# Start path selection
			is_dragging = true
			start_tile = get_cursor_tile(event.position)
			last_tile = start_tile
			get_tile_path(parent.target_position)

			#parent.target_position = parent.camera.get_global_mouse_position()
		elif not event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			# Stop updating path as mouse is released
			is_dragging = false
			
	return null
	
func process_physics(delta: float) -> State:
	
	var velocity : Vector2  = move_towards_target(delta, parent.target_position)
	
	# If the mouse is still being held down,
	# prevent state change but update animation
	if is_dragging:
		if velocity == Vector2.ZERO:
			parent.animated_sprite.animation = idle_animations[parent.direction]
		else:
			parent.animated_sprite.animation = animations[parent.direction]
	else:
		# If the mouse is released and not moving, return to idle
		if velocity == Vector2.ZERO:
			return check_interaction()
			
	# Flip the sprite if facing left
	if velocity.x != 0:
		parent.animated_sprite.flip_h = velocity.x < 0
		
	# Start movement
	velocity = velocity.normalized() * move_speed

	parent.position += velocity * delta
	parent.move_and_slide()
	
	return null

func process_frame(_delta: float) -> State:
	
	# Start the building operation
	if ready_to_build:
		return build_state
		
	# If the mouse is being dragged, update cursor position
	if is_dragging:
		cursor_position = parent.camera.get_global_mouse_position()
		var current_tile : Vector2i = get_cursor_tile(cursor_position)

		if current_tile != last_tile and current_tile.distance_to(last_tile) > 5:
			last_tile = current_tile
			set_target_position(cursor_position)
			get_tile_path(parent.target_position)
	
	return null

func get_a_star() -> Node:
	
	if pathfinder == null and parent != null:
		pathfinder = parent.a_star_pathfinding
	return pathfinder

func set_target_position(position: Vector2) -> void:
	
	parent.target_position = position

func get_cursor_tile(cursor_pos: Vector2) -> Vector2i:
	
	return pathfinder.world_to_grid(cursor_pos)

func get_tile_path(target_position: Vector2) -> void:
	# Find the nearest valid tile
	var target_tile : Vector2i = pathfinder.get_closest_tile(target_position)

	# Preserve previous path progress
	var previous_target_index : int = current_target_index
	var previous_tile_path : Array = tile_path.duplicate()

	# Get the new path
	tile_path = pathfinder.get_tile_path(
		parent.global_position, 
		pathfinder.grid_to_world(target_tile)
	)

	# Handle path updates
	handle_path_update(previous_tile_path, previous_target_index)
	
func handle_path_update(
	previous_tile_path: Array, 
	previous_target_index: int
) -> void:
	if is_valid_path(previous_tile_path) and is_valid_path(tile_path):
		# Find and update the target index based on the previous path
		current_target_index = find_closest_tile_index(
			previous_tile_path, previous_target_index
		)
	else:
		current_target_index = 0

func is_valid_path(path: Array) -> bool:
	# Checks if a path is valid
	return path.size() > 0

func find_closest_tile_index(
	previous_tile_path: Array, 
	previous_target_index: int
) -> int:
	# Ensure previous_target_index is within bounds
	var clamped_index : int = clamp(
		previous_target_index, 0, previous_tile_path.size() - 1
	)

	# Find the closest tile
	var closest_index := 0
	var min_distance := INF
	var previous_tile : Vector2i = previous_tile_path[clamped_index]

	for i in range(tile_path.size()):
		var distance : float = previous_tile.distance_to(tile_path[i])
		if distance < min_distance:
			min_distance = distance
			closest_index = i
	
	return closest_index

func move_towards_target(_delta: float, target_position: Vector2) -> Vector2:
	
	# Calculate a new path if there isn't one
	if tile_path.size() == 0:
		get_tile_path(target_position)
	
	# If we reached the end of the tile path, stop moving
	if current_target_index >= tile_path.size():
		return Vector2.ZERO
	
	var current_target: Vector2 = tile_path[current_target_index]
	
	# Calculate the direction vector to the target position
	var direction: Vector2 = (
		current_target - parent.global_position
	).normalized()
	
	# Ensure we are actually stopping at the tile center
	var distance_to_target := parent.global_position.distance_to(current_target)
	if distance_to_target <= 2:  # Small threshold for stopping
		current_target_index += 1
		if current_target_index >= tile_path.size():
			# Ensure final snap to tile center
			parent.position = tile_path[-1]
			return Vector2.ZERO  # Stop moving
		
		current_target = tile_path[current_target_index]
		direction = (current_target - parent.global_position).normalized()
	
		# Get the animation direction based on which is closest to the object
		parent.direction = get_closest_direction(direction)
		
	# Calculate the velocity
	var velocity: Vector2 = direction * parent.player_speed
	return velocity

func face_object(target: Node2D) -> void:
	# Get the direction vector form the player to the target
	var direction : Vector2 = (
		(target.global_position - parent.global_position).normalized()
	)
	
	# Get the closest direction
	var closest_direction : Vector2 = get_closest_direction(direction)
	
	parent.animated_sprite.animation = idle_animations[closest_direction]

func get_closest_direction(direction: Vector2) -> Vector2:
	
	# Calculate dot products with each main direction
	var dot_right: float = direction.dot(Vector2.RIGHT)
	var dot_left: float = direction.dot(Vector2.LEFT)
	var dot_up: float = direction.dot(Vector2.UP)
	var dot_down: float = direction.dot(Vector2.DOWN)

	# Determine which direction has the highest dot product (most aligned)
	var max_dot: float = max(dot_right, dot_left, dot_up, dot_down)

	# Set default priority order for cases where directions are equally close
	if max_dot == dot_right:
		return Vector2.RIGHT
	elif max_dot == dot_left:
		return Vector2.LEFT
	elif max_dot == dot_up:
		return Vector2.UP
	else:
		return Vector2.DOWN

func check_interaction() -> State:
	# If there is a target object that was clicked
	if parent.interact_target:
		face_object(parent.interact_target)
		return gather_state
	parent.animated_sprite.animation = idle_animations[parent.direction]
	return idle_state

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
