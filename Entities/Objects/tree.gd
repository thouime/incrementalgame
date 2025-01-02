extends "res://Entities/Objects/gathering_interact.gd"
	
func interact_action(player: CharacterBody2D) -> void:

	print("Gathering from tree, player is:", player)
	# Specific tree logic
	# Randomize leaves and sticks to be added to inventory
