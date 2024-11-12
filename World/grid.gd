extends Control

var tile_size: Vector2 = Vector2(16, 16)
@export var world_grid_width: int = 100
@export var world_grid_height: int = 100

var world_grid_visible = false

#func _draw():
	#for row in range(world_grid_height):
		#for col in range(world_grid_width):
			#var x = col * tile_size.x
			#var y = row * tile_size.y
			#
			## Draw the top and bottom horizontal lines for each tile
			#draw_line(Vector2(x, y), Vector2(x + tile_size.x, y), Color(1, 1, 1), 1)  # Top
			#draw_line(Vector2(x, y + tile_size.y), Vector2(x + tile_size.x, y + tile_size.y), Color(1, 1, 1), 1)  # Bottom
			#
			## Draw the left and right vertical lines for each tile
			#draw_line(Vector2(x, y), Vector2(x, y + tile_size.y), Color(1, 1, 1), 1)  # Left
			#draw_line(Vector2(x + tile_size.x, y), Vector2(x + tile_size.x, y + tile_size.y), Color(1, 1, 1), 1)  # Right

func draw_grid(cursor_pos: Vector2) -> void:
	var rows: int  = 5
	var cols: int = 5
	var padding: int = 8 # Padding between cells
	
	# Calculate the center offset in terms of grid cells
	var center_offset_x = cols / 2
	var center_offset_y = rows / 2
	
	# Set start position based on cursor position
	var start_pos_x = int(cursor_pos.x / tile_size.x) - center_offset_x
	var start_pos_y = int(cursor_pos.y / tile_size.y) - center_offset_y
	
	# Clear existing grid cells before redrawing
	for child in self.get_children():
		child.queue_free()
	
	for row in range(rows):
		for col in range(cols):
			# Skip drawing the center cell
			if row == center_offset_y and col == center_offset_x:
				continue
				
			var cell = ColorRect.new()
			var cell_x = start_pos_x + col
			var cell_y = start_pos_y + row
			cell.custom_minimum_size = tile_size - Vector2(padding, padding)
			cell.color = Color(1, 1, 1, 0.2) # Slightly transparent color
			# Calculate cell position in the world, applying padding and centering the cell within each tile
			cell.position = Vector2(
				(cell_x * tile_size.x) + (padding / 2),
				(cell_y * tile_size.y) + (padding / 2)
			)
			self.add_child(cell)
	
func toggle_grid_lines() -> void:
	world_grid_visible = !world_grid_visible
	#queue_redraw()
