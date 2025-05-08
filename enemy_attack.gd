extends "res://Entities/Enemy/StateMachine/enemy_state.gd"

@export var chase_state : EnemyState

# How much time before next attack
var attack_cooldown := 0.0

func enter() -> void:
	print("Entered enemy attack state!")
	parent.animated_sprite.play("Idle")
	parent.animated_sprite.animation_finished.connect(_on_animation_finished)

func exit() -> void:
	parent.animated_sprite.animation_finished.disconnect(_on_animation_finished)

func process_physics(delta: float) -> EnemyState:
	
	if attack_cooldown > 0:
		attack_cooldown -= delta
	
	if not target_in_range(parent.attack_range):
		return chase_state
	
	if attack_cooldown <= 0:
		perform_attack()
		attack_cooldown = 1.0 / parent.attack_speed
	
	return null
	
func process_frame(_delta: float) -> EnemyState:
	
	return null

func target_in_range(distance: float) -> bool:
	
	if not parent.target:
		printerr("This is no target!")
		return false
	
	var target_position = parent.target.global_position
	
	if parent.global_position.distance_to(target_position) <= distance:
		return true
		
	return false

func get_attack_direction() -> String:
	
	var target = parent.target
	# Get direction to target (player)
	var direction : Vector2 = (
		target.global_position - parent.global_position
	).normalized()
	
	if abs(direction.x) > abs(direction.y):
		return "Attack_Right" if direction.x > 0 else "Attack_Left"
	else:
		return "Attack_Down" if direction.y > 0 else "Attack_Up"

func perform_attack() -> void:
	# atttack animation
	parent.animated_sprite.play(get_attack_direction())
	# reduce health

func _on_animation_finished() -> void:
	print("animation finished")
	if parent.animated_sprite.animation.begins_with("Attack"):
		parent.animated_sprite.play("Idle")
