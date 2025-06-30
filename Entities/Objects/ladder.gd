extends "object.gd"

signal dungeon_exit

func _ready() -> void:
	super._ready()
	# Initialize all the drops added from the editor
	set_object_name("ladder")

func interact_action(_player: CharacterBody2D) -> void:
	print("Interacted With Ladder!")
	dungeon_exit.emit()

func stop_interact_action(_player: CharacterBody2D) -> void:
	pass
