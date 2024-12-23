extends Node

@export var initial_state : State
var current_state : State
# Keep track of events for transitioning between states
var event_queue : Array = []
# Keep track of the last direction the player was facing for animations
var last_direction: Vector2 = Vector2.UP
# Keep track of the current interacting object
var interact_target: Node = null
var crafting_system: Node = null

func _ready() -> void:
	# Connect signals for state changes outside the scope of each state
	_connect_signals()

# Initialize the state machine by giving each child state a reference to the
# parent object it belongs to and enter the default initial_state
func init(parent: Player, crafting_system_ref: Node) -> void:
	for child in get_children():
		child.parent = parent
	
	crafting_system = crafting_system_ref
	
	# Initialize to the default state
	change_state(initial_state)

func change_state(new_state: State) -> void:
	if current_state:
		current_state.exit()
	
	current_state = new_state
	PlayerManager.player_state = current_state
	if current_state.has_signal("stop_building"):
		current_state.stop_building_signal(crafting_system)
	current_state.enter()
	
	print("Processing queue...")
	# Process any queued events after the state has transitioned
	process_queue()

func enqueue_event(event_data):
	event_queue.append(event_data)

# Handle and remove the next event added to the queue
func process_queue():
	while event_queue.size() > 0:
		var event_data = event_queue.pop_front()
		handle_event(event_data)

func handle_event(event_data):
	if current_state:
		current_state.handle_event(event_data)

# Pass through functions for the Player to call,
# handling state changes as needed.
func process_physics(delta: float) -> void:
	var new_state : State = current_state.process_physics(delta)
	if new_state:
		change_state(new_state)

func process_input(event: InputEvent) -> void:
	var new_state : State = current_state.process_input(event)
	if new_state:
		change_state(new_state)

func process_frame(delta: float) -> void:
	var new_state : State = current_state.process_frame(delta)
	if new_state:
		change_state(new_state)

func _connect_signals() -> void:
	_connect_interact_signals()
	_connect_crafting_signal()

func _connect_interact_signals() -> void:
	for node in get_tree().get_nodes_in_group("interactables"):
		if not node.is_connected("interact", _on_interact_signal):
			node.connect("interact", _on_interact_signal)
	
func _on_interact_signal(pos: Vector2, offset: float, object: StaticBody2D) -> void:
	if current_state and current_state.has_method("_on_interact_signal"):
		current_state._on_interact_signal(pos, offset, object)

func _connect_crafting_signal() -> void:
	if CraftingSystem.has_signal("build_object"):
		CraftingSystem.connect("build_object", _on_build_object)

func _on_build_object() -> void:
	#enqueue_event({"type": "craft", "data": data})
	enqueue_event({"type": "craft", "data": null})
	if current_state and current_state.has_method("start_building"):
		current_state.start_building()
