class_name PlayerBuilding
extends State

signal stop_building

@export var idle_state : State
var done_building : bool = false
var crafting_system : Node = null
var grid_active : bool = false
var placement_mode : bool = false
var tile_info : TileInfo = null
var num_tiles : int
var grass_tiles : TileMapLayer = null
@onready var grid: Control = $Grid

func enter() -> void:
	parent.animated_sprite.animation = idle_animations[parent.direction]
	print("Entered Building State")
	
func exit() -> void:
	done_building = false
	if stop_building.is_connected(crafting_system._on_stop_building):
		stop_building.disconnect(crafting_system._on_stop_building)
	if crafting_system.is_connected("stop_building", self._on_stop_building):
		crafting_system.disconnect("stop_building", self._on_stop_building)
	crafting_system = null # Clear the reference to avoid stale data
	print("Exited Building State")

func process_input(event: InputEvent) -> State:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			print("Left mouse button pressed!")
			if grid_active and placement_mode:
				build_tile()
		# Handle cancel action (e.g., pressing the "cancel" action key)
		if event.is_action_pressed("cancel"):
			stop_building.emit()
			return idle_state
	return null

func process_frame(_delta: float) -> State:
	# Change to build state
	if done_building:
		return idle_state
	if grid_active:
		draw_grid()
	return null

func place_tile(tile: TileInfo) -> void:
	
	print("Now placing tile!")
	grass_tiles = CraftingSystem.grass_tiles
	tile_info = tile
	
	grid.center_cursor()
	# Change the cursor to the sprite of the craft
	grid.set_cursor_texture(tile.tile_texture)
	draw_grid()
	
	# Check if there is dirt in the inventory
	# Set num tiles
	print("Preparing grid...")


func build_tile() -> void:
	# When finishing building check if there's more dirt
	# If no more dirt stop placing tiles
	# Cancel/esc to stop building
	
	var tilemap_coordinates: Vector2  = grass_tiles.local_to_map(
		grid.get_global_mouse_position()
	)
	grass_tiles.set_cell(tilemap_coordinates, 0, tile_info.tile_map_coordinates)
	
	#items_to_remove = remove the resource for the tile

func draw_grid() -> void:
	grid.draw_grid()
	grid.update_cursor()
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	grid.build_cursor.visible = true
	grid_active = true
	grid.visible = true
	placement_mode = true

	
func stop_building_signal(crafting_system_node : Node) -> void:
	crafting_system = crafting_system_node
	stop_building.connect(crafting_system._on_stop_building)
	crafting_system.connect("stop_building", _on_stop_building)

func _on_stop_building() -> void:
	done_building = true
