class_name PlayerIdle
extends State

@export var key_move_state : State
@export var click_move_state: State
@export var gather_state : State
@export var build_state : State

func enter() -> void:
	parent.velocity = Vector2(0, 0)
	parent.animated_sprite.animation = idle_animations[parent.direction]

func exit() -> void:
	pass

func process_input(event: InputEvent) -> State:
	# Check for movement inputs
	for action in directions.keys():
		if Input.is_action_just_pressed(action):
			return key_move_state
	return null
	
func process_physics(delta: float) -> State:
	parent.move_and_slide()
	
	# Check if a target position is set and switch to click move state
	if parent.target_position:
		return click_move_state
	
	return null

# Check if they are already interacting with the same object
#if not object == interact_target:
	## Interrupt player if they are already gathering
	#if state == State.GATHERING and interact_target:
		#interact_target.stop_interact_action(self)
	#target_position = pos
	## Target underneath the object so player is in the front
	#target_position.y += offset
	#state = State.MOVING

func _on_interact_signal(
	pos: Vector2, 
	offset: float,
	object: StaticBody2D
) -> void:
	# Check if they are already interacting with the same object
	if object != parent.interact_target:
		parent.interact_target = object
		
		# Interrupt player if they are already gathering
		#if interact_target:
			#interact_target.stop_interact_action(self)
		
		parent.target_position = pos
		# Target underneath the object so player is in the front
		parent.target_position.y += offset
