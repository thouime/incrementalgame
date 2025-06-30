@tool
extends Marker2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = Engine.is_editor_hint()
