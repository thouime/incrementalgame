class_name  GatheringInteract
extends "object.gd"

## Time to gather before receiving loot.
@export var gather_time: float = 2.0
## Number of interactions before depletion.
@export var interact_limit: int = 10
## Duration of time before resource regenerates.
@export var regen_duration: float = 60

var timer: Timer
var current_interacts: int = 0

func _ready() -> void:
	super._ready()
	object_type = "Gathering"

func interact_action(player: CharacterBody2D) -> void:
	start_timer(player)

func start_timer(player: CharacterBody2D) -> void:
	timer = Timer.new()
	add_child(timer)
	timer.wait_time = gather_time
	timer.one_shot = false
	timer.timeout.connect(_on_timer_timeout.bind(player))
	timer.start()

func stop_interact_action(_player: CharacterBody2D) -> void:
	if timer:
		timer.stop()
		timer.queue_free()
		timer = null
		print("Stopped gathering.")

func is_gathering() -> bool:
	print("Need to overrite this statement and use activity timer!")
	return false

func _on_timer_timeout(_player: CharacterBody2D) -> void:
	print("Timer timeout sent")
