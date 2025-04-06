extends Node2D

# Array of tiles to highlight
var tiles_to_highlight: Array = []

# Color of the highlighting
var highlight_color: Color = Color(1, 0, 0, 0.5)  # Red with 50% opacity
# Darker green for final target tile
var target_color: Color = Color(0, 0.2, 0, 0.5)

func _process(_delta : float) -> void:
	queue_redraw()

func _draw() -> void:
	# Loop through each tile in the tiles_to_highlight array
	for i in range(tiles_to_highlight.size()):
		var tile : Vector2 = tiles_to_highlight[i]
		
		# Adjust by half the size of a tile (8, 8)
		var offset_tile : Vector2 = tile - Vector2(8, 8)

		# Create a Rect2 using the adjusted position and tile size
		var rect := Rect2(offset_tile, Vector2(16, 16))
		
		# Choose the appropriate color for the current tile
		var color_to_use : Color = highlight_color
		if i + 1 == tiles_to_highlight.size():  # If this is the last tile, use the target color
			color_to_use = target_color
		
		# Draw the rectangle with the chosen color
		draw_rect(rect, color_to_use, true)

# Call this function to update the highlighted tiles
func update_highlight(tiles : Array) -> void:
	tiles_to_highlight = tiles
	queue_redraw()  # Trigger the _draw method
