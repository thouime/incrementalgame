class_name State
extends Node

@export var move_speed: int = 200
# Hold a reference to the parent so that it can be controlled by the state
var parent: Player
# Store sprite animations
var directions = {
	"move_right": Vector2.RIGHT,
	"move_left": Vector2.LEFT,
	"move_down": Vector2.DOWN,
	"move_up": Vector2.UP
}
var animations = {
	Vector2.RIGHT: "walk_right",
	Vector2.LEFT: "walk_left",
	Vector2.DOWN: "walk_down",
	Vector2.UP: "walk_up"
}
var idle_animations = {
	Vector2.RIGHT: "idle_right",
	Vector2.LEFT: "idle_left",
	Vector2.DOWN: "idle_down",
	Vector2.UP: "idle_up"
}
# Handle building state using a variable that gets changed via signal
var ready_to_build: bool = false
var craft_slot: CraftData

# Code the runs when entering the state
func enter():
	#parent.animated_sprite.play(animations[animation_name])
	pass

# Handles exiting state and transitioning to new state
func exit():
	pass

func process_input(event: InputEvent) -> State:
	return null

func process_frame(delta: float) -> State:
	return null

func process_physics(delta: float) -> State:
	return null

func start_building() -> void:
	ready_to_build = true
