extends "res://Entities/Enemy/StateMachine/enemy_state.gd"

func enter() -> void:
	print("Entered chase state")
	set_animation()

func exit() -> void:
	pass
	
func process_physics(_delta: float) -> EnemyState:
	
	set_animation()
	
	parent.velocity = parent.direction * parent.speed
	
	parent.move_and_slide()
	
	return null

func process_frame(_delta: float) -> EnemyState:
	
	return null

func set_animation() -> void:
	
	var direction = parent.velocity
	if direction:
		parent.animated_sprite.play("Walking")
		parent.animated_sprite.flip_h = direction.x < 0
