extends Node2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func start_animation() -> void:
	animated_sprite_2d.play("Indicator")
	
func stop_animation() -> void:
	animated_sprite_2d.stop()
