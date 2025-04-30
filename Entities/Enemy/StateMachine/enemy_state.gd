class_name EnemyState
extends Node

# Hold a reference to the parent so that it can be controlled by the state
var parent: Enemy

# Code the runs when entering the state
func enter() -> void:
	pass

# Handles exiting state and transitioning to new state
func exit() -> void:
	pass

func process_input(_event: InputEvent) -> EnemyState:
	return null

func process_frame(_delta: float) -> EnemyState:
	return null

func process_physics(_delta: float) -> EnemyState:
	return null
