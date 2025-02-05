class_name State
extends Node

signal Transitioned

@export var move_speed: int = 200
# Hold a reference to the parent so that it can be controlled by the state
var parent: Player
# Store sprite animations
var directions : Dictionary = {
	"move_right": Vector2.RIGHT,
	"move_left": Vector2.LEFT,
	"move_down": Vector2.DOWN,
	"move_up": Vector2.UP
}
var animations : Dictionary = {
	Vector2.RIGHT: "walk_right",
	Vector2.LEFT: "walk_left",
	Vector2.DOWN: "walk_down",
	Vector2.UP: "walk_up"
}
var idle_animations : Dictionary = {
	Vector2.RIGHT: "idle_right",
	Vector2.LEFT: "idle_left",
	Vector2.DOWN: "idle_down",
	Vector2.UP: "idle_up"
}
var craft_slot: CraftData

# Code the runs when entering the state
func enter() -> void:
	pass

# Handles exiting state and transitioning to new state
func exit() -> void:
	pass

func handle_event(event_data: Dictionary) -> void:
	print("Handling event: %s" % event_data)

func process_input(_event: InputEvent) -> State:
	return null

func process_frame(_delta: float) -> State:
	return null

func process_physics(_delta: float) -> State:
	return null

func get_next_state(_event_data: Dictionary) -> State:
	print("This state doesn't have a get_next_state method!")
	return null
