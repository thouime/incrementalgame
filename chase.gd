extends "res://Entities/Enemy/StateMachine/enemy_state.gd"

@export var idle_state : EnemyState
@export var attack_state : EnemyState

func enter() -> void:
	print("Entered chase state")
	set_animation()

func exit() -> void:
	pass
	
func process_physics(_delta: float) -> EnemyState:
	
	set_animation()
	
	parent.velocity = parent.direction * parent.speed
	
	# Check if target is out of range to stop chasing
	if not target_in_range(parent.chase_range * 2):
		return idle_state
	
	var target_position = parent.target.global_position
	parent.nav_agent.target_position = target_position
	
	var next_point = parent.nav_agent.get_next_path_position()
	var direction = (next_point - parent.global_position).normalized()
	var push_force = get_separation_force()
	var movement_velocity = direction * parent.speed
	parent.velocity = movement_velocity + push_force
	
	parent.move_and_slide()
	
	if target_in_range(parent.attack_range):
		return attack_state
	
	return null

func process_frame(_delta: float) -> EnemyState:
	
	return null

func set_animation() -> void:
	
	var direction = parent.velocity
	if direction:
		parent.animated_sprite.play("Walking")
		parent.animated_sprite.flip_h = direction.x < 0

func target_in_range(distance: float) -> bool:
	
	if not parent.target:
		printerr("This is no target!")
		return false
	
	var target_position = parent.target.global_position
	
	if parent.global_position.distance_to(target_position) <= distance:
		return true
		
	return false

# A force that keeps enemies from bunching up on top of eachother
func get_separation_force():
	
	var push_force := Vector2.ZERO
	var separation_radius := 32
	for other in get_tree().get_nodes_in_group("enemy"):
		if other == parent:
			continue
			
		var offset : Vector2 = (
			parent.global_position - other.global_position
		)
		
		var distance := offset.length()
		
		var repulsion = (separation_radius - distance) / separation_radius
		if distance > 0 and distance < separation_radius:
			push_force += offset.normalized() * repulsion
	
	return push_force * 50
