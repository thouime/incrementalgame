extends Control

@export var tile_size: Vector2 = Vector2(16, 16)
@export var grid_size: Vector2 = Vector2(32, 32)
@export var world_grid_width: int = 100
@export var world_grid_height: int = 100

# Temporary variable for the cursor during grid view
@onready var build_cursor: Sprite2D = $Cursor

var world_grid_visible: bool = false

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

func center_cursor() -> void:
	# Get the size of the window
	var window_size: Vector2 = get_viewport().get_visible_rect().size
	var center_position: Vector2 = window_size / 2
	
	# Move the cursor to the center
	Input.warp_mouse(center_position)

func set_cursor(sprite: Sprite2D) -> void:
	
	const CURSOR_SIZE = Vector2(32, 32)
	
	# Texture is a default
	if sprite:
		build_cursor.texture = sprite.texture
		
		var texture_size : Vector2
		
		# Check if the passed sprite uses a region
		if sprite.region_enabled:
			build_cursor.region_enabled = true
			build_cursor.region_rect = sprite.region_rect  # Set the same region
			texture_size = build_cursor.region_rect.size
		else:
			# If no region, use the full texture
			build_cursor.region_enabled = false
			build_cursor.region_rect = Rect2()  # Reset region rectangle
			texture_size = build_cursor.texture.get_size()
		
		# Scale the cursor size in the case of different sized textures
		var scale_factor = CURSOR_SIZE / texture_size
		build_cursor.set_scale(scale_factor)

func set_cursor_texture(
	texture: Texture2D,
	 region_enabled: bool = false, 
	region_rect: Rect2 = Rect2()
) -> void:
	# Set the texture directly
	if texture:
		build_cursor.texture = texture
		# If a region is provided, set it
		if region_enabled:
			build_cursor.region_enabled = true
			build_cursor.region_rect = region_rect
		else:
			build_cursor.region_enabled = false  # Use the full texture
			build_cursor.region_rect = Rect2()  # Reset region rectangle

# Optional parameter that forces cursor snapping to grid size
func update_cursor(use_grid_size: bool = false) -> void:
	var cursor_pos: Vector2 = get_global_mouse_position()
	var snapped_x: int
	var snapped_y: int
	
	if use_grid_size:
		# Snap based on grid size
		snapped_x = floor(cursor_pos.x / grid_size.x) * grid_size.x
		snapped_y = floor(cursor_pos.y / grid_size.y) * grid_size.y
	else:
		# Snap based on tile size (default behavior)
		snapped_x = floor(cursor_pos.x / tile_size.x) * tile_size.x
		snapped_y = floor(cursor_pos.y / tile_size.y) * tile_size.y
	
	var snapped_position: Vector2 = Vector2(snapped_x, snapped_y)
	var offset: Vector2 = (grid_size - tile_size) / 2
	
	# Adjusted padding (for grid cells in your visual layout)
	var padding: int = 16
	
	# Center the build cursor
	build_cursor.position = (
		snapped_position + 
		offset + 
		Vector2(int(float(padding) / 2), int(float(padding) / 2))
	)

func get_cursor(use_grid_size: bool = false) -> Vector2:
	var cursor_pos: Vector2 = get_global_mouse_position()
	var snapped_x: int
	var snapped_y: int
	
	if use_grid_size:
		# Snap based on grid size
		snapped_x = floor(cursor_pos.x / grid_size.x) * grid_size.x
		snapped_y = floor(cursor_pos.y / grid_size.y) * grid_size.y
	else:
		# Snap based on tile size (default behavior)
		snapped_x = floor(cursor_pos.x / tile_size.x) * tile_size.x
		snapped_y = floor(cursor_pos.y / tile_size.y) * tile_size.y
	
	var snapped_position: Vector2 = Vector2(snapped_x, snapped_y)
	var offset: Vector2 = (grid_size - tile_size) / 2
	
	# Adjusted padding (for grid cells in your visual layout)
	var padding: int = 16
	
	var build_position: Vector2 = (
		snapped_position + 
		offset + 
		Vector2(int(float(padding) / 2), int(float(padding) / 2))
	)
	return build_position
	
func draw_grid(use_grid_size: bool = false) -> void:
	var cursor_pos: Vector2 = get_global_mouse_position()
	var rows: int = 5
	var cols: int = 5

	# Calculate center offsets for centering
	var center_offset_x: int = int(float(cols) / 2.0)
	var center_offset_y: int = int(float(rows) / 2.0)
	
	var snapped_cursor_x: int
	var snapped_cursor_y: int

	if use_grid_size:
		# Snap the cursor position based on tile size
		snapped_cursor_x = floor(cursor_pos.x / grid_size.x) * grid_size.x
		snapped_cursor_y = floor(cursor_pos.y / grid_size.y) * grid_size.y
	else:
		snapped_cursor_x = floor(cursor_pos.x / tile_size.x) * tile_size.x
		snapped_cursor_y = floor(cursor_pos.y / tile_size.y) * tile_size.y
		
	# Adjust padding
	var padding: int = int(tile_size.x)
	
		# Calculate total grid size including padding based on selected size
	var total_grid_width: int
	var total_grid_height: int
	
	if use_grid_size:
		# Use grid size for calculations
		total_grid_width = int(cols * grid_size.x + (cols - 1) * padding - tile_size.x * 2)
		total_grid_height = int(rows * grid_size.y + (rows - 1) * padding - tile_size.y * 2)
	else:
		# Use tile size for calculations
		total_grid_width = int(cols * grid_size.x + (cols - 1) * padding - tile_size.x * 2)
		total_grid_height = int(rows * grid_size.y + (rows - 1) * padding - tile_size.y * 2)

	# Center the start position based on total grid dimensions
	# Align grid to center
	var start_x: int = int(snapped_cursor_x - int(total_grid_width / 2.0))  # Make sure to use float for division
	var start_y: int = int(snapped_cursor_y - int(total_grid_height / 2.0))  # Make sure to use float for division

	# Clear previous ColorRect nodes
	for child in self.get_children():
		if child is ColorRect:
			child.queue_free()

	# Create grid with padding
	for row in range(rows):
		for col in range(cols):
			# Skip the center cell if necessary
			if row == center_offset_y and col == center_offset_x:
				continue

			var cell: ColorRect = ColorRect.new()
			cell.custom_minimum_size = grid_size  # Set visual size to 32x32
			cell.color = Color(1, 1, 1, 0.2)

			# Position the cell with padding applied
			cell.position = Vector2(
				start_x + (col * (grid_size.x + padding)),
				start_y + (row * (grid_size.y + padding))
			)

			self.add_child(cell)

func toggle_grid_lines() -> void:
	world_grid_visible = !world_grid_visible
	#queue_redraw()
