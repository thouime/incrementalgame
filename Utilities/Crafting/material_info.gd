extends HBoxContainer

@onready var texture_rect: TextureRect = $TextureRect
@onready var material_name: Label = $MaterialName
@onready var material_quantity: Label = $MaterialQuantity

func set_info(texture: Texture, mat_name: String, quantity: int) -> void:
	texture_rect.texture = texture
	material_name.text = mat_name + ":"
	material_quantity.text = "x" + str(quantity)
