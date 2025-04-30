extends Node
class_name AIStateMachine

signal state_changed(state: EnemyState)

@export var initial_state : EnemyState
var current_state : EnemyState
# Keep track of the last direction the enemy was facing
var last_direction : Vector2 = Vector2.UP

# Initialize the state machine by giving each child state a reference to the
# parent object it belongs to and enter the default initial_state
func init(parent: Enemy) -> void:
	for child in get_children():
		child.parent = parent
	
	# Initialize to the default state
	change_state(initial_state)
	

func change_state(new_state: EnemyState) -> void:
	if current_state:
		current_state.exit()
	
	current_state = new_state

	current_state.enter()
	
	state_changed.emit()

# Pass through functions for the Player to call,
# handling state changes as needed.
func process_physics(delta: float) -> void:
	var new_state : EnemyState = current_state.process_physics(delta)
	if new_state:
		change_state(new_state)

func process_input(event: InputEvent) -> void:
	var new_state : EnemyState = current_state.process_input(event)
	if new_state:
		change_state(new_state)

func process_frame(delta: float) -> void:
	var new_state : EnemyState = current_state.process_frame(delta)
	if new_state:
		change_state(new_state)

func _on_state_changed() -> void:
	if current_state:
		state_changed.disconnect(_on_state_changed)
		
