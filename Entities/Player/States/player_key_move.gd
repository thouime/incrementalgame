class_name PlayerKeyMove
extends State

@export var idle_state : State
@export var gather_state : State
@export var build_state : State
var ready_to_build : bool = false

func enter() -> void:
	parent.target_position = Vector2.ZERO
	parent.interact_target = null
	
func exit() -> void:
	ready_to_build = false
	
func process_input(_event: InputEvent) -> State:
	# Check for movement inputs
	for action : String in directions.keys():
		# Remove target for clicking objects if an object is clicked while moving
		# Should only click object to move if it's clicked just after movement
		if Input.is_action_just_released(action):
			parent.target_position = Vector2.ZERO
	return null
	
func process_physics(delta: float) -> State:
	var velocity : Vector2 = handle_key_movement()
	if velocity.length() > 0:
		# Set movement animations
		parent.animated_sprite.animation = animations[parent.direction]

		# Flip the sprite if facing left
		if velocity.x != 0:
			parent.animated_sprite.flip_h = velocity.x < 0
			
		# Start movement
		velocity = velocity.normalized() * move_speed
		parent.position += velocity * delta
		parent.move_and_slide()
	else:
		return idle_state
		
	return null

func process_frame(_delta: float) -> State:
	# Start the building operation
	if ready_to_build:
		return build_state
	
	return null

func handle_key_movement() -> Vector2:
	var velocity : Vector2 = Vector2.ZERO
	# Check for movement inputs
	for action : String in directions.keys():
		if Input.is_action_pressed(action):
			# Get direction based on the key pressed
			var direction : Vector2 = directions[action]
			velocity += direction
			parent.direction = direction
	return velocity

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
