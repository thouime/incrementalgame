class_name EnemyIdle
extends EnemyState

@export var wander_state : EnemyState

func enter() -> void:
	
	parent.animated_sprite.play("Idle")

func exit() -> void:
	
	pass
	
func process_physics(_delta: float) -> EnemyState:
	
	parent.move_and_slide()
	
	return null

func process_frame(_delta: float) -> EnemyState:
	
	if parent.positions:
		return wander_state
	
	return null
