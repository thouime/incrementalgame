extends "res://Entities/Objects/gathering_interact.gd"

@onready var activity_timer: ActivityTimer = $ActivityTimer

func _ready() -> void:
	super._ready()
	# Initialize all the drops added from the editor
	drop_table.setup()
	set_object_name("bush")
	activity_timer.timer_finished.connect(_on_gather_timeout)
	activity_timer.set_time(gather_time)

# Override
func _default_interact() -> void:
	# Specific bush logic
	activity_timer.start()
	print("Gathering from bush...")

func stop_interact_action(_player: CharacterBody2D) -> void:
	if not harvester:
		activity_timer.stop()

func is_gathering() -> bool:
	return activity_timer.is_running()

func _on_timer_timeout(_player: CharacterBody2D) -> void:
	pass
		
func _on_gather_timeout() -> void:
	super._on_gather_timeout()
	activity_timer.start()
