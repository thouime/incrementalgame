extends "res://Entities/Enemy/enemy.gd"

# Combat values
@export var attack_range : float
# How many attacks per second
@export var attack_speed : float

@export var chase_range : float
# Debugging enemy chase range
@export var draw_range : bool = false

var goal_position : Vector2
var home_position : Vector2
var direction : Vector2 = Vector2.ZERO
var positions : Array
var target : CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var state_machine: AIStateMachine = $StateMachine
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D

func _ready() -> void:
	self.enemy_name = "Goblin"
	home_position = global_position
	state_machine.init(self)
	target = PlayerManager.player

func _unhandled_input(event: InputEvent) -> void:
	state_machine.process_input(event)
	
func _physics_process(delta: float) -> void:
	state_machine.process_physics(delta)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	state_machine.process_frame(delta)
	queue_redraw()

func _draw() -> void:
	if draw_range:
		draw_circle(Vector2.ZERO, chase_range / scale.x, Color(1, 0, 0, 0.5))
		var distance_to_target : float = global_position.distance_to(
			target.global_position
		)
		if distance_to_target < chase_range:
			draw_line(
				to_local(global_position), 
				to_local(target.global_position), 
				Color.GREEN
			)

func get_direction(dir: Vector2) -> String:
	if abs(dir.x) > abs(dir.y):
		return "right" if dir.x > 0 else "left"
	else:
		return "down" if dir.y > 0 else "up"

func _on_direction_updated(new_direction: Vector2) -> void:
	velocity = (
		new_direction.normalized() * speed
		if new_direction.length() > 0
		else Vector2.ZERO
	)

func hit(damage: int) -> void:
	health -= damage
	if damage > 0:
		hit_flash()
	if health <= 0:
		if has_method("on_death"):
			on_death()
		else:
			queue_free()

func hit_flash() -> void:
	var tween := create_tween()
	animated_sprite.modulate = Color.RED
	tween.tween_property(animated_sprite, "modulate", Color.WHITE, 0.1)

func on_death() -> void:
	var tween:= create_tween()
	tween.tween_property(
		self, "modulate:a", 0.0, 0.5
	).set_trans(Tween.TRANS_LINEAR)
	tween.tween_callback(Callable(self, "queue_free"))
