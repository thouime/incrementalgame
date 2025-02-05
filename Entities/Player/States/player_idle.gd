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

func process_input(_event: InputEvent) -> State:
	# Check for movement inputs
	for action : String in directions.keys():
		if Input.is_action_just_pressed(action):
			return key_move_state
	return null
	
func process_physics(_delta: float) -> State:
	parent.move_and_slide()
	
	# Check if a target position is set and switch to click move state
	if parent.target_position:
		return click_move_state
	
	return null

func get_next_state(event_data: Dictionary) -> State:
	match event_data.type:
		"build":
			return build_state
		"craft":
			return build_state
		_:
			return null

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
