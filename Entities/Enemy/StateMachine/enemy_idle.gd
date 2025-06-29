class_name EnemyIdle
extends EnemyState

@export var wander_state : EnemyState
@export var chase_state : EnemyState

func enter() -> void:
	
	parent.animated_sprite.play("Idle")

func exit() -> void:
	
	pass
	
func process_physics(_delta: float) -> EnemyState:
	
	# Check if target is close enough to start chasing
	if target_in_range(parent.chase_range):
		return chase_state
	
	if not is_home:
		return_home()
		set_animation()
	
	parent.move_and_slide()
	
	return null

func process_frame(_delta: float) -> EnemyState:
	
	if parent.positions and is_home:
		return wander_state
	
	return null

# Check and return to the home position
func is_home() -> bool:
	
	var home_distance : float = parent.global_position.distance_to(
		parent.home_position
	)
	
	if home_distance > 4:
		parent.nav_agent.set_target_position(parent.home_position)
		return false
		
	return true
		

func return_home() -> void:
	
	var target_position : Vector2 = parent.home_position
	parent.nav_agent.target_position = target_position
	
	var next_point : Vector2 = parent.nav_agent.get_next_path_position()
	var direction : Vector2 = (next_point - parent.global_position).normalized()
	var push_force : Vector2 = get_separation_force()
	var movement_velocity : Vector2 = direction * parent.speed
	parent.velocity = movement_velocity + push_force

func get_separation_force() -> Vector2:
	
	var push_force := Vector2.ZERO
	var separation_radius := 32
	for other in get_tree().get_nodes_in_group("enemy"):
		if other == parent:
			continue
			
		var offset : Vector2 = (
			parent.global_position - other.global_position
		)
		
		var distance := offset.length()
		
		var repulsion : float = (separation_radius - distance) / separation_radius
		if distance > 0 and distance < separation_radius:
			push_force += offset.normalized() * repulsion
	
	return push_force * 50

func set_animation() -> void:
	
	var direction : Vector2 = parent.velocity
	if direction:
		parent.animated_sprite.play("Walking")
		parent.animated_sprite.flip_h = direction.x < 0

func target_in_range(distance: float) -> bool:
	
	if not parent.target:
		printerr("This is no target!")
		return false
	
	var target_position : Vector2 = parent.target.global_position
	
	if parent.global_position.distance_to(target_position) <= distance:
		return true
		
	return false
