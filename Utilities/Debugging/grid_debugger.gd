extends Node2D

@export var world: Node2D  # The parent node containing your TileMapLayer(s)
@export var grid_color: Color = Color(1, 0, 0, 0.5)  # Red grid lines with transparency

func _draw():
	if world == null:
		return

	# Loop through each child of 'world' that is a TileMapLayer
	var ground_layer = world.get_node("Grass")
	draw_tilemaplayer_grid(ground_layer)

# Function to draw the grid for a specific TileMapLayer
func draw_tilemaplayer_grid(layer: TileMapLayer):
	var tile_set = layer.tile_set  # Access the TileSet from the TileMapLayer
	if tile_set:
		var tile_size = tile_set.get_tile_size()  # Get the size of the tiles from the TileSet

		# Convert tile_size to Vector2 (as TileSize is Vector2i)
		var tile_size_f = Vector2(tile_size.x, tile_size.y)

		# Get the bounds of the TileMapLayer in local space
		var map_rect = layer.get_used_rect()  # Get the rectangle of used tiles in this TileMapLayer
		var start_pos = map_rect.position
		var end_pos = map_rect.end

		# Get the world position of the TileMapLayer's origin (0, 0 tile) in world space
		var layer_position = layer.global_position  # Position of the TileMapLayer in the parent world space
		var tilemap_origin_world_pos = layer_position  # 0,0 of the TileMapLayer in world space

		# Loop through all the tiles and draw grid lines
		# Convert start_pos and end_pos to world space
		start_pos = Vector2(start_pos.x * tile_size_f.x, start_pos.y * tile_size_f.y) + tilemap_origin_world_pos
		end_pos = Vector2(end_pos.x * tile_size_f.x, end_pos.y * tile_size_f.y) + tilemap_origin_world_pos

		# Convert start_pos and end_pos to Vector2i since we're dealing with tilemap grid coordinates
		var start_pos_int = Vector2i(floor(start_pos.x / tile_size_f.x), floor(start_pos.y / tile_size_f.y))
		var end_pos_int = Vector2i(floor(end_pos.x / tile_size_f.x), floor(end_pos.y / tile_size_f.y))

		# Loop through all the tiles and draw grid lines
		# Draw vertical grid lines
		for x in range(start_pos_int.x, end_pos_int.x + 1):
			var start_pos_local = layer.map_to_local(Vector2i(x, start_pos_int.y))
			var end_pos_local = layer.map_to_local(Vector2i(x, end_pos_int.y))
			
			# Convert start_pos_local and end_pos_local to Vector2 before subtracting the tile size
			start_pos_local = Vector2(start_pos_local.x, start_pos_local.y) - tile_size_f / 2
			end_pos_local = Vector2(end_pos_local.x, end_pos_local.y) - tile_size_f / 2

			draw_line(start_pos_local, end_pos_local, grid_color, 1)

		# Draw horizontal grid lines
		for y in range(start_pos_int.y, end_pos_int.y + 1):
			var start_pos_local = layer.map_to_local(Vector2i(start_pos_int.x, y))
			var end_pos_local = layer.map_to_local(Vector2i(end_pos_int.x, y))
			
			# Convert start_pos_local and end_pos_local to Vector2 before subtracting the tile size
			start_pos_local = Vector2(start_pos_local.x, start_pos_local.y) - tile_size_f / 2
			end_pos_local = Vector2(end_pos_local.x, end_pos_local.y) - tile_size_f / 2

			draw_line(start_pos_local, end_pos_local, grid_color, 1)
