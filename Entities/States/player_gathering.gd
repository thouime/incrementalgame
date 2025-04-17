class_name PlayerGathering
extends State

@export var key_move_state : State
@export var click_move_state: State
@export var build_state : State
var ready_to_build : bool = false
var is_interacting : bool = false

func enter() -> void:
	parent.velocity = Vector2(0, 0)
	parent.target_position = Vector2.ZERO
	gather_from_target()

func exit() -> void:
	ready_to_build = false
	is_interacting = false

# Check for inputs
func process_input(event: InputEvent) -> State:
	# Check for movement inputs
	for action : String in directions.keys():
		if Input.is_action_just_pressed(action):
			interrupt_state()
			return key_move_state
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			if is_interacting:
				return null
			interrupt_state()
			parent.interact_target = null
			parent.target_position = parent.camera.get_global_mouse_position()
			
	return null
	
func process_physics(_delta: float) -> State:
	parent.move_and_slide()
	
	# Check if a target position is set and switch to click move state
	if parent.target_position:
		return click_move_state
	
	return null

func process_frame(_delta: float) -> State:
	# Start the building operation
	if ready_to_build:
		return build_state
	
	return null

# Srtart gathering
func gather_from_target() -> void:
	# Gather animation
	if parent.interact_target:
		parent.interact_target.interact_action(parent)
	else:
		print("There is no interact target!")

# Anything that interrupts gathering such as key movement should clear the
# reference to the interact object
func interrupt_state() -> void:
	if parent.interact_target:
		parent.interact_target.stop_interact_action(parent)

func _on_interact_signal(
	pos: Vector2, 
	offset: float,
	object: StaticBody2D
) -> void:
	
	is_interacting = true
	# Check if they are already interacting with the same object
	if object != parent.interact_target or not object.is_gathering():

		# Interrupt player if they are already gathering
		interrupt_state()
			
		# Set the interact_target to the new target
		parent.interact_target = object
		parent.target_position = pos
		# Target underneath the object so player is in the front
		parent.target_position.y += offset

func start_building() -> void:
	ready_to_build = true
