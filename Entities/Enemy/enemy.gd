extends CharacterBody2D
class_name Enemy

@export var speed : int = 75

var health : int :
	get():
		return health
	set(value):
		health = value
@export var attack : int :
	get():
		return attack
	set(value):
		attack = value

var enemy_name : String = "Enemy"

func get_attack_damage() -> int:
	var min_damage = attack * 0.8
	var max_damage = attack * 1.2
	return randi_range(min_damage, max_damage)
