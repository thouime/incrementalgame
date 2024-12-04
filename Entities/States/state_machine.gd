extends Node

@export var initial_state : State
var current_state : State
# Keep track of the last direction the player was facing for animations
var last_direction: Vector2 = Vector2.UP
# Keep track of the current interacting object
var interact_target: Node = null

# Initialize the state machine by giving each child state a reference to the
# parent object it belongs to and enter the default initial_state
func init(parent: Player) -> void:
	for child in get_children():
		child.parent = parent
	
	# Initialize to the default state
	change_state(initial_state)
	
	call_deferred("_connect_interact_signals")

func change_state(new_state: State) -> void:
	if current_state:
		current_state.exit()
	
	current_state = new_state
	current_state.enter()

# Pass through functions for the Player to call,
# handling state changes as needed.
func process_physics(delta: float) -> void:
	var new_state = current_state.process_physics(delta)
	if new_state:
		change_state(new_state)

func process_input(event: InputEvent) -> void:
	var new_state = current_state.process_input(event)
	if new_state:
		change_state(new_state)

func process_frame(delta: float) -> void:
	var new_state = current_state.process_frame(delta)
	if new_state:
		change_state(new_state)

func _connect_interact_signals() -> void:
	for node in get_tree().get_nodes_in_group("interactables"):
		if not node.is_connected("interact", _on_interact_signal):
			node.connect("interact", _on_interact_signal)
			
func _on_interact_signal(pos: Vector2, offset: float, object: StaticBody2D) -> void:
	if current_state and current_state.has_method("_on_interact_signal"):
		current_state._on_interact_signal(pos, offset, object)
