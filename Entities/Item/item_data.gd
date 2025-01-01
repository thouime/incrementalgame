extends Resource

class_name ItemData

@export var name: String = ""
@export_multiline var description: String = ""
@export var _stackable: bool = false 
@export var texture: AtlasTexture

# Abstract method to be inherited
func use(_target: CharacterBody2D) -> void:
	pass

func get_stackable() -> bool:
	return _stackable

func set_stackable(value: bool) -> void:
	_stackable = value
