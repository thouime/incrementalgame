extends Node

signal state_changed(state: State)

@export var initial_state : State
var current_state : State
# Keep track of the last direction the player was facing for animations
var last_direction : Vector2 = Vector2.UP
# Keep track of the current interacting object
var interact_target : Node = null
var crafting_system : Node = null
# For passing the tile to the building state
var building_tile : TileInfo = null
var tile_map := TileMap
var a_star_pathfinding : Node

# Initialize the state machine by giving each child state a reference to the
# parent object it belongs to and enter the default initial_state
func init(parent: Player, crafting_system_ref: Node) -> void:
	for child in get_children():
		child.parent = parent
	
	crafting_system = crafting_system_ref
	a_star_pathfinding = parent.a_star_pathfinding
	
	# Initialize to the default state
	change_state(initial_state)
	
	_connect_interact_signals.call_deferred()
	_connect_crafting_signal.call_deferred()

func change_state(new_state: State) -> void:
	if current_state:
		current_state.exit()
	
	current_state = new_state
	PlayerManager.player_state = current_state
	if current_state.has_signal("stop_building"):
		current_state.stop_building_signal(crafting_system)
	current_state.enter()
	
	state_changed.emit()

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

func _connect_interact_signals() -> void:
	for node in get_tree().get_nodes_in_group("interactables"):
		if not node.is_connected("interact", _on_interact_signal):
			node.connect("interact", _on_interact_signal)
	
func _on_interact_signal(
	pos: Vector2, offset: float, object: StaticBody2D
) -> void:
	if current_state and current_state.has_method("_on_interact_signal"):
		current_state._on_interact_signal(pos, offset, object)

func _connect_crafting_signal() -> void:
	if CraftingSystem.has_signal("start_building"):
		CraftingSystem.connect("start_building", _on_building_signal)

func _on_building_signal() -> void:
	if current_state and current_state.has_method("start_building"):
		current_state.start_building()
		
func _handle_building_tile(tile: TileInfo) -> void:
	if current_state and current_state.has_method("start_building"):
		var inventory: InventoryData = PlayerManager.player.inventory_data
		if inventory.check_total(tile.item) <= 0:
			print("Player does not have the resources to create the tile!")
			return
		current_state.start_building()
		building_tile = tile
		# Connect to state change signal to call place_tile after transition
		if not state_changed.is_connected(_on_state_changed):
			state_changed.connect(_on_state_changed)
			
func _on_state_changed() -> void:
	if current_state and building_tile:
		if not current_state.has_method("place_tile"):
			return
		current_state.place_tile(building_tile)
		building_tile = null
		state_changed.disconnect(_on_state_changed)
		
