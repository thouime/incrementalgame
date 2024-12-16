extends ColorRect

@export var value : float = 0.0
@export var max_value : float = 100.0
@export var min_value : float = 0.0

func _ready() -> void:
	set_value(value)
	
func set_value(new_value: float) -> void:
	value = clamp(new_value, min_value, max_value)
	material.set_shader_parameter("value", value)
