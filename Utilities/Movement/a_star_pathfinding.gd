extends Node

var world : Node2D
var tile_map_ground : TileMapLayer
var tile_map_boundary : TileMapLayer
var astar := AStar2D.new()
var tile_size: Vector2

func initialize_astar(world_node: Node2D) -> void:
	world = world_node
	if world:
		tile_map_ground = world.get_node("Grass")
		tile_map_boundary = world.get_node("Boundary")
		tile_size = tile_map_ground.tile_set.tile_size
		get_tiles()

func get_tiles() -> void:
	var used_tiles = tile_map_ground.get_used_cells()  # Layer 0
	for tile in used_tiles:
		add_point(tile)

	# Connect neighboring tiles
	for tile in used_tiles:
		for dx in [-1, 0, 1]:
			for dy in [-1, 0, 1]:
				if dx == 0 and dy == 0:
					continue
				var neighbor = Vector2(tile.x + dx, tile.y + dy)
				if tile_map_ground.get_cell_source_id(neighbor) != -1:  # Check if neighbor exists
					connect_points(tile, neighbor)

func add_point(tile: Vector2) -> void:
	var point_id = get_point_id(tile)
	astar.add_point(point_id, tile)
	
func connect_points(tile_a: Vector2, tile_b: Vector2) -> void:
	var point_id_a = get_point_id(tile_a)
	var point_id_b = get_point_id(tile_b)
	if astar.has_point(point_id_a) and astar.has_point(point_id_b):
		astar.connect_points(point_id_a, point_id_b)

func get_point_id(tile: Vector2) -> int:
	return int(tile.x + tile.y * tile_map_ground.get_used_rect().size.x)

func world_to_grid(position: Vector2) -> Vector2:
	return tile_map_ground.local_to_map(position)

func grid_to_world(tile: Vector2) -> Vector2:
	return tile_map_ground.map_to_local(tile)

func get_tile_path(start: Vector2, end: Vector2) -> Array:
	var start_tile = world_to_grid(start)
	var end_tile = world_to_grid(end)
	
	var start_id = get_point_id(start_tile)
	var end_id = get_point_id(end_tile)
	
	if astar.has_point(start_id) and astar.has_point(end_id):
		var path_tiles = astar.get_point_path(start_id, end_id)
		var path_world = []
		for tile in path_tiles:
			path_world.append(grid_to_world(tile))
		return path_world
	return []

func update_tile(tile: Vector2, is_walkable: bool) -> void:
	var point_id = get_point_id(tile)
	if is_walkable:
		if not astar.has_point(point_id):
			add_point(tile)
			# Reconnect to neighbors
			for dx in [-1, 0, 1]:
				for dy in [-1, 0, 1]:
					if dx == 0 and dy == 0:
						continue
					var neighbor = Vector2(tile.x + dx, tile.y + dy)
					if tile_map_ground.get_tile_source_id(0, neighbor) != -1:
						connect_points(tile, neighbor)
	else:
		if astar.has_point(point_id):
			astar.remove_point(point_id)
