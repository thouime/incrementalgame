extends EnemyState
class_name Wander

signal direction_updated(direction: Vector2)

@export var idle_state : EnemyState
@export var chase_state : EnemyState

var rand_positions : Array
var is_waiting : bool = false

@onready var wait_timer: Timer = $WaitTimer

func enter() -> void:
	rand_positions = get_positions()
	get_next_position()
	wait_timer.timeout.connect(_on_wait_finished)

func exit() -> void:
	parent.direction = Vector2.ZERO
	parent.velocity = Vector2.ZERO
	is_waiting = false
	wait_timer.stop()
	wait_timer.timeout.disconnect(_on_wait_finished)
	
func process_physics(_delta: float) -> EnemyState:
	
	# Check if target is close enough to start chasing
	if target_in_range(parent.chase_range):
		return chase_state
	
	if is_waiting or parent.positions.is_empty():
		return
	
	if parent.global_position.distance_to(parent.current_position) < 36:
		parent.direction = Vector2.ZERO
		parent.velocity = Vector2.ZERO
		set_animation()
		is_waiting = true
		wait_timer.wait_time = randi_range(1, 3)
		wait_timer.start()
	
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
	else:
		parent.animated_sprite.play("Idle")

func get_positions() -> Array:
	
	var new_positions = parent.positions.duplicate()
	new_positions.shuffle()
	return new_positions
	
func get_next_position() -> void:
	
	if rand_positions.is_empty():
		rand_positions = get_positions()
	parent.current_position = rand_positions.pop_front()
	parent.direction = parent.to_local(parent.current_position).normalized()
	direction_updated.emit(parent.direction)

func _on_wait_finished() -> void:
	
	is_waiting = false
	get_next_position()
	
func target_in_range(distance: float) -> bool:
	
	if not parent.target:
		printerr("This is no target!")
		return false
	
	var target_position = parent.target.global_position
	
	if parent.global_position.distance_to(target_position) <= distance:
		return true
		
	return false
