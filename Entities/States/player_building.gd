class_name PlayerBuilding
extends State

signal stop_building

@export var idle_state : State
var done_building : bool = false
var crafting_system : Node = null
var grid_active : bool = false
var placement_mode : bool = false
var tile_info : TileInfo = null
var grass_tiles : TileMapLayer = null
var boundary_tiles : TileMapLayer = null
var inventory : InventoryData
# Keep track of the materials needed for placing tiles
var material_slots : Dictionary = {}
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
	inventory = null
	grass_tiles = null
	boundary_tiles = null
	tile_info = null
	material_slots.clear()
	print("Exited Building State")

func process_input(event: InputEvent) -> State:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if grid_active and placement_mode:
				var tiles_to_build: Array = search_tiles(
					grid.get_global_mouse_position(),
					grass_tiles
				)
				build_tile(tiles_to_build)
	# Handle cancel action (e.g., pressing the "cancel" action key)
	if event.is_action_pressed("cancel"):
		cancel_place_tile()
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
	boundary_tiles = CraftingSystem.boundary_tiles
	tile_info = tile
	
	# Check if there is dirt in the inventory
	inventory = PlayerManager.player_inventory
	var inventory_slots: Dictionary = inventory.check_materials_available(
		tile_info.item
	)
	material_slots.merge(inventory_slots)
	if material_slots[tile_info.item]["total"] > 0:
		print("Preparing grid...")
		grid.center_cursor()
		# Change the cursor to the sprite of the craft
		grid.set_cursor_texture(tile.tile_texture)
		draw_grid()
	else:
		print("You need at least ", 1, " ", tile_info.name, " to build!")
		
func build_tile(tiles_to_build: Array) -> void:
	# Check if there are empty tiles to add tiles to
	if tiles_to_build.is_empty():
		print("There are already tiles there!")
		return
		
	var tilemap_global_position: Vector2 = grass_tiles.global_position
	var global_mouse_position: Vector2 = grid.get_global_mouse_position()
	var tilemap_coordinates: Vector2 = grass_tiles.local_to_map(
		global_mouse_position - tilemap_global_position
	)
	add_tile(tiles_to_build, grass_tiles)
	add_boundary(tilemap_coordinates, boundary_tiles)
	check_and_remove_boundary(grid.get_global_mouse_position(), boundary_tiles)
	inventory.reduce_slot_amount(tile_info.item, 1)
	# Remove total materials from dictionary
	material_slots[tile_info.item]["total"] -= 1
	if material_slots[tile_info.item]["total"] <= 0:
		cancel_place_tile()

func search_tiles(
	cursor_position: Vector2, 
	tile_map_layer: TileMapLayer
) -> Array:
	# Convert the world position to the local position relative to the tilemap
	var local_position: Vector2 = tile_map_layer.to_local(cursor_position)
	
	# Convert to map coordinates
	var clicked_tile: Vector2 = tile_map_layer.local_to_map(local_position)
	
	# Check a 2x2 area
	var tiles_to_check: Vector2 = Vector2(2, 2)
	
	# Store empty tiles
	var empty_tiles: Array = []
	
	# Loop through the affected tiles
	for x in range(clicked_tile.x, clicked_tile.x + tiles_to_check.x):
		for y in range(clicked_tile.y, clicked_tile.y + tiles_to_check.y):
			var tile_position: Vector2i = Vector2i(x, y)
			var data: TileData = tile_map_layer.get_cell_tile_data(Vector2i(x, y))
	
			if not data: # If there is a tile data at this position
				empty_tiles.append(tile_position)
			else:
				print("There is already a tile placed there!")

	# If there are tiles in the given area
	return empty_tiles

func add_tile(
	empty_tiles: Array,
	tiles: TileMapLayer
) -> void:
	for tile_position: Vector2 in empty_tiles:
		# Add a tile at the position
		tiles.set_cell(
			tile_position,
			0,
			tile_info.tile_map_coordinates
		)

# Place 1x1 boundary tiles around each of the newly placed grass tiles individually
func add_boundary(
	tilemap_coordinates: Vector2,
	tiles: TileMapLayer
) -> void:
	# Check the adjacent cells outside the 2x2 area of the placed tiles
	for x in range(-1, 3):  # From -1 to 2 to check all adjacent positions
		for y in range(-1, 3):  # From -1 to 2 to check all adjacent positions
			# Skip the 2x2 area that was just placed
			if x >= 0 and x < 2 and y >= 0 and y < 2:
				continue
			
			# Calculate the adjacent position
			var adjacent_position: Vector2 = tilemap_coordinates + Vector2(x, y)
			var adjacent_data: TileData = grass_tiles.get_cell_tile_data(adjacent_position)
			
			# If there's no tile in the adjacent cell, place a boundary tile
			if !adjacent_data:
				# Place a 1x1 boundary tile here (boundary tiles will be placed individually)
				tiles.set_cell(
					adjacent_position, 
					0,  # Use the correct boundary tile ID here
					tile_info.tile_boundary.tile_map_coordinates
				)

func check_and_remove_boundary(
	position: Vector2, 
	tiles: TileMapLayer
) -> void:
	# Convert the position to local coordinates in the boundary_tiles layer
	var local_position: Vector2 = tiles.to_local(position)
	
	# Convert local coordinates to map coordinates (tile grid positions)
	var clicked_cell: Vector2 = tiles.local_to_map(local_position)
	
	# Define the size of the area to check (2x2 grid)
	var cells_to_check: Vector2 = Vector2(2, 2)
	
	# Loop through the 2x2 grid area and check each tile
	for x in range(clicked_cell.x, clicked_cell.x + cells_to_check.x):
		for y in range(clicked_cell.y, clicked_cell.y + cells_to_check.y):
			# Get the tile data for the current position
			var data: TileData = tiles.get_cell_tile_data(Vector2i(x, y))
			
			if data:
				# If a boundary tile is found, remove it by setting it to an invalid tile ID (e.g., -1)
				print("Removing boundary tile at position: ", x, y)
				tiles.set_cell(Vector2(x, y), -1)  # Set the tile to empty

func draw_grid() -> void:
	grid.draw_grid()
	grid.update_cursor()
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	grid.build_cursor.visible = true
	grid_active = true
	grid.visible = true
	placement_mode = true

func cancel_place_tile() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	grid.build_cursor.visible = false
	grid_active = false
	grid.visible = false
	placement_mode = false
	done_building = true

func stop_building_signal(crafting_system_node : Node) -> void:
	crafting_system = crafting_system_node
	stop_building.connect(crafting_system._on_stop_building)
	crafting_system.connect("stop_building", _on_stop_building)

func _on_stop_building() -> void:
	done_building = true
