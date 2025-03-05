extends Node

var world : Node2D
var tile_map_ground : TileMapLayer
var tile_map_boundary : TileMapLayer
var astar := AStar2D.new()
var tile_size: Vector2
var restricted_tiles := []
@onready var mark_tile_path: Node2D = $MarkTilePath

func initialize_astar(world_node: Node2D) -> void:
	world = world_node
	if not world:
		return
		
	tile_map_ground = world.get_node("Grass")
	tile_map_boundary = world.get_node("Boundary")
	tile_size = tile_map_ground.tile_set.tile_size
	get_tiles()
	
	for object in get_tree().get_nodes_in_group("interactables"):
		restricted_tiles.append_array(get_object_tiles(object))
	
	mark_restricted_tiles(restricted_tiles)

func get_tiles() -> void:
	var used_tiles : Array[Vector2i] = tile_map_ground.get_used_cells() 
	for tile : Vector2i in used_tiles:
		add_point(tile)

	# Connect neighboring tiles
	for tile : Vector2i in used_tiles:
		for dx : int in [-1, 0, 1]:
			for dy : int in [-1, 0, 1]:
				if dx == 0 and dy == 0:
					continue
				var neighbor: Vector2i = Vector2i(tile.x + dx, tile.y + dy)
				if tile_map_ground.get_cell_source_id(neighbor) != -1:  # Check if neighbor exists
					connect_points(tile, neighbor)

func add_point(tile: Vector2) -> void:
	var point_id : int = get_point_id(tile)
	astar.add_point(point_id, tile)
	
func connect_points(tile_a: Vector2i, tile_b: Vector2i) -> void:
	var point_id_a : int = get_point_id(tile_a)
	var point_id_b : int = get_point_id(tile_b)
	if astar.has_point(point_id_a) and astar.has_point(point_id_b):
		astar.connect_points(point_id_a, point_id_b)

func get_point_id(tile: Vector2) -> int:
	var rect: Rect2i = tile_map_ground.get_used_rect()
	return int(tile.x - rect.position.x + (
		tile.y - rect.position.y * rect.size.x 
	) * rect.size.x)

func world_to_grid(position: Vector2) -> Vector2:
	# Convert global position to local position relative to the TileMap
	var local_pos : Vector2 = tile_map_ground.to_local(position)
	 
	# Convert local position to tile coordinates
	return tile_map_ground.local_to_map(local_pos)

func grid_to_world(tile: Vector2) -> Vector2:
	
	# Convert tile coordinates to local coordinates
	var local_pos : Vector2 = tile_map_ground.map_to_local(tile)
	
	# Adjust to top-left corner by subtracting half of tile size (16x16)
	local_pos -= Vector2(8, 8) # Adjust for the center-to-top-left difference
	
	# Convert local coordinates to global coordinates
	var global_pos : Vector2 = tile_map_ground.to_global(local_pos)
	return global_pos

func get_tile_path(start: Vector2, end: Vector2) -> Array:
	
	# Convert Global Coordinates to Tile Coordinates
	var start_tile : Vector2i = world_to_grid(start)
	var end_tile : Vector2i = world_to_grid(end)

	var start_id : int = get_point_id(start_tile)
	var end_id : int = get_point_id(end_tile)
	
	if astar.has_point(start_id) and astar.has_point(end_id):
		var path_tiles : Array = astar.get_point_path(start_id, end_id)
		var path_world := []
		for tile : Vector2 in path_tiles:
			path_world.append(grid_to_world(tile))
			
		# Draw tile path
		show_tile_path(path_world)
		
		return path_world
	return []

func update_tile(tile: Vector2, is_walkable: bool) -> void:
	var point_id : int = get_point_id(tile)
	if is_walkable:
		if not astar.has_point(point_id):
			add_point(tile)
			# Reconnect to neighbors
			for dx : int in [-1, 0, 1]:
				for dy : int in [-1, 0, 1]:
					if dx == 0 and dy == 0:
						continue
					var neighbor := Vector2(tile.x + dx, tile.y + dy)
					if tile_map_ground.get_tile_source_id(0, neighbor) != -1:
						connect_points(tile, neighbor)
	else:
		if astar.has_point(point_id):
			astar.remove_point(point_id)

func get_object_tiles(object: Node2D) -> Array:
	var tiles := []
	var unwalkable_shape := object.get_node("NotWalkable")
	
	if unwalkable_shape:
		var global_pos : Vector2 = unwalkable_shape.global_position
		var size : Vector2 = unwalkable_shape.size * 2 # Objects are scaled
		var top_left = world_to_grid(global_pos)
		var bottom_right : Vector2i = world_to_grid(global_pos + size)
	
		for x : int in range(top_left.x, bottom_right.x + 1):
			for y : int in range(top_left.y, bottom_right.y + 1):
				tiles.append(Vector2(x, y))
				
	return tiles
	
func mark_restricted_tiles(tiles: Array) -> void:
	
	for tile : Vector2 in tiles:
		var point_id : int = get_point_id(tile)
		if astar.has_point(point_id):
			astar.remove_point(point_id)
			

# Show the path in colored rectangles
func show_tile_path(tiles: Array) -> void:
	$MarkTilePath.update_highlight(tiles)
	
