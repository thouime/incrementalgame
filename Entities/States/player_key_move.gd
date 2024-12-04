class_name PlayerKeyMove
extends State

@export var idle_state : State
@export var gather_state : State
@export var build_state : State

func enter() -> void:
	parent.target_position = Vector2.ZERO
	parent.interact_target = null
	
func process_input(event: InputEvent) -> State:
	return null
	
func process_physics(delta: float) -> State:
	var velocity = handle_key_movement()
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

func handle_key_movement() -> Vector2:
	var velocity = Vector2.ZERO
	# Check for movement inputs
	for action in directions.keys():
		if Input.is_action_pressed(action):
			# Get direction based on the key pressed
			var direction = directions[action]
			velocity += direction
			parent.direction = direction
	return velocity

func _on_interact_signal(
	pos: Vector2, 
	offset: float,
	object: StaticBody2D
) -> void:
		
	print("Interact Signal!")
