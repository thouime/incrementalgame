extends "object.gd"

@export var gather_time: float = 2.0
var timer: Timer

func _ready() -> void:
	super._ready()

func interact_action(player: CharacterBody2D) -> void:
	start_timer(player)

func start_timer(player: CharacterBody2D) -> void:
	timer = Timer.new()
	add_child(timer)
	timer.wait_time = gather_time
	timer.one_shot = false
	timer.timeout.connect(_on_timer_timeout.bind(player))
	timer.start()

func stop_interact_action(player: CharacterBody2D) -> void:
	if timer:
		timer.stop()
		timer.queue_free()
		timer = null
		print("Stopped gathering.")
	
func _on_timer_timeout(player: CharacterBody2D) -> void:
	print("Timer timeout sent")
