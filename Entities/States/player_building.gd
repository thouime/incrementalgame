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
	print("Exited Building State")

func process_input(event: InputEvent) -> State:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if grid_active and placement_mode:
				build_tile()
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
	tile_info = tile
	
	# Check if there is dirt in the inventory
	inventory = PlayerManager.player_inventory
	var inventory_slots: Dictionary = inventory.check_materials_available(
		tile_info.item
	)
	material_slots.merge(inventory_slots)
	print(material_slots)
	if material_slots[tile_info.item]["total"] > 0:
		print("Preparing grid...")
		grid.center_cursor()
		# Change the cursor to the sprite of the craft
		grid.set_cursor_texture(tile.tile_texture)
		draw_grid()
	else:
		print("You need at least ", 1, " ", tile_info.name, " to build!")
		
func build_tile() -> void:
	# When finishing building check if there's more dirt
	# If no more dirt stop placing tiles
	# Cancel/esc to stop building
	

	var tilemap_global_position = grass_tiles.global_position
	var global_mouse_position = grid.get_global_mouse_position()
	var tilemap_coordinates: Vector2 = grass_tiles.local_to_map(
		global_mouse_position - tilemap_global_position
	)
	
	
	for x in range(2):
		for y in range(2):
			var position = tilemap_coordinates + Vector2(x, y)
			grass_tiles.set_cell(
				position, 
				0, 
				tile_info.tile_map_coordinates
			)
	
	#inventory.reduce_slot_amount()
	
	#items_to_remove = remove the resource for the tile
	
	#if material_slots[tile_info][]

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
	# empty dictionary
	# clean up tile stuff

func stop_building_signal(crafting_system_node : Node) -> void:
	crafting_system = crafting_system_node
	stop_building.connect(crafting_system._on_stop_building)
	crafting_system.connect("stop_building", _on_stop_building)

func _on_stop_building() -> void:
	done_building = true
