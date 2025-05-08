extends CharacterBody2D
class_name Enemy

@export var speed : int = 75

var health : int :
	get():
		return health
	set(value):
		health = value
var attack : int :
	get():
		return attack
	set(value):
		attack = value

var enemy_name : String = "Enemy"
