extends CharacterBody2D
class_name Enemy

@export var speed : int = 75

@export var health : int :
	get():
		return health
	set(value):
		health = value
		
@export var attack_power : int :
	get():
		return attack_power
	set(value):
		attack_power = value

var enemy_name : String = "Enemy"

func get_attack_damage() -> int:
	var min_damage := int(attack_power * 0.8)
	var max_damage := int(attack_power * 1.2)
	return randi_range(min_damage, max_damage)
