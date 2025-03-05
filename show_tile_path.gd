extends Node2D

# Array of tiles to highlight
var tiles_to_highlight: Array = []

# Color for highlighting
var highlight_color: Color = Color(1, 0, 0, 0.5)  # Red with 50% opacity

func _process(_delta : float) -> void:
	queue_redraw()

func _draw() -> void:
	for tile : Vector2 in tiles_to_highlight:
		var rect := Rect2(tile, Vector2(16, 16))
		draw_rect(rect, highlight_color, true)

# Call this function to update the highlighted tiles
func update_highlight(tiles : Array) -> void:
	tiles_to_highlight = tiles
	queue_redraw()  # Trigger the _draw method
	print("Updating drawn path...")
