class_name PlayerClickMove
extends State

@export var idle_state : State
@export var gather_state : State
@export var build_state : State
@export var key_move_state : State
var ready_to_build : bool = false

func enter() -> void:
	pass

func exit() -> void:
	parent.velocity = Vector2.ZERO
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
	# Calculate the direction vector to the target position
	var direction : Vector2 = (target_position - parent.global_position).normalized()
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
	_pos: Vector2, 
	_offset: float,
	_object: StaticBody2D
) -> void:
		
	print("Interact Signal!")
	
func start_building() -> void:
	ready_to_build = true
