class_name PlayerBuilding
extends State

signal stop_building

@export var idle_state : State
var done_building : bool = false
var crafting_system : Node = null

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
	# Check for movement inputs
	# Handle cancel action (e.g., pressing the "cancel" action key)
	if event.is_action_pressed("cancel"):
		stop_building.emit()
		return idle_state
	return null

func process_frame(_delta: float) -> State:
	# Change to build state
	if done_building:
		return idle_state
	return null

func place_tile(tile: TileInfo) -> void:
	print(tile.tile_map_coordinates)
	print("Now placing tile!")
	var grass_tiles : TileMapLayer = CraftingSystem.grass_tiles
	var tilemap_coordinates: Vector2  = grass_tiles.local_to_map(Vector2(-100, -100))
	#grass_tiles.set_cell(Vector2i(1, 1), 0, tile.tile_map_coordinates)
	grass_tiles.set_cell(tilemap_coordinates, 0, tile.tile_map_coordinates)
	
	# Check if there is dirt in the inventory
	
	# When finishing building check if there's more dirt
	# If no more dirt stop placing tiles
	# Cancel/esc to stop building
	# Set cursor to sprite of tile
	print("Preparing grid...")
	#var new_object: StaticBody2D = craft_slot.object_scene.instantiate()
	#var sprite: Sprite2D = new_object.get_node("Sprite1")
	#
	## Ensure unique material and shader
	#preview_object = new_object
	#items_to_remove = material_slots
	## Change the cursor to the sprite of the craft
	#grid.set_cursor(sprite)
	#draw_grid()
	

	
func stop_building_signal(crafting_system_node : Node) -> void:
	crafting_system = crafting_system_node
	stop_building.connect(crafting_system._on_stop_building)
	crafting_system.connect("stop_building", _on_stop_building)

func _on_stop_building() -> void:
	done_building = true
