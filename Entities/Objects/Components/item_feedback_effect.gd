extends Node2D

@export var gain_color: Color = Color(0, 1, 0, 1)  # Green for gain
@export var consume_color: Color = Color(1, 0, 0, 1)  # Red for consume

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var label: Label = $Control/Label
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func setup(
		icon: AtlasTexture, 
		quantity: int, 
		is_gain: bool, 
		duration: float = 3,
	) -> void:
	sprite_2d.texture = icon
	sprite_2d.scale = Vector2(0.35, 0.35)
	label.text = "+" if is_gain else "-"
	label.text += str(quantity)
	label.modulate = gain_color if is_gain else consume_color
	set_duration(duration)
	set_sprite_position()
	set_label_position()
	self.show()
	
	var animation_name : String = "gain" if is_gain else "consume"
	animation_player.animation_finished.connect(_on_animation_finished)
	animation_player.play(animation_name)
	
# Set duration of all animations to the given float
func set_duration(duration: float) -> void:
	for anim_string: String in animation_player.get_animation_list():
		var anim : Animation = animation_player.get_animation(anim_string)
		anim.length = duration

func set_sprite_position() -> void:
	var object : Node2D = get_parent()
	var sprite_width: float
	var padding: float = 12
	for child in object.get_children():
		if child is Sprite2D:
			sprite_width = child.get_rect().size.x
			break
	self.global_position = Vector2(
		object.position.x + sprite_width + padding, 
		object.position.y + 50
	)

func set_label_position() -> void:
	var sprite_height: float = sprite_2d.texture.get_height() * sprite_2d.scale.y
	# Labels position themselves relative to the parent node
	var label_parent: Control = label.get_parent()
	
	# Set the label centered to the right of the sprite
	label_parent.position = Vector2(5, -sprite_height / 2)

func _on_animation_finished(_anim_name: String) -> void:
	queue_free()
