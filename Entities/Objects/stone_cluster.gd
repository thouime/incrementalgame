extends "res://Entities/Objects/gathering_interact.gd"

@onready var activity_timer: ActivityTimer = $ActivityTimer
@onready var sprite: Sprite2D = $Sprite1

func _ready() -> void:
	super._ready()
	# Initialize all the drops added from the editor

	set_object_name("stone_cluster")
	activity_timer.timer_finished.connect(_on_gather_timeout)
	activity_timer.set_time(gather_time)
	activity_timer.show()

# Override
func interact_action(_player: CharacterBody2D) -> void:

	if current_interacts < interact_limit:
		activity_timer.start()
		print("Gathering from stone cluster...")
	elif activity_timer.regen_complete:
		print("regen complete true")
		current_interacts = 0
		activity_timer.start()
		print("Gathering from stone cluster...")

func stop_interact_action(_player: CharacterBody2D) -> void:
	activity_timer.stop()

func is_gathering() -> bool:
	return activity_timer.is_running()

func _on_timer_timeout(_player: CharacterBody2D) -> void:
	pass
		
func _on_gather_timeout() -> void:
	super._on_gather_timeout()

	# Start the regeneration of the resource, set as regen duration in export
	if current_interacts >= interact_limit:
		print("Resource has been depleted! It needs to regenerate...")
		activity_timer.start_regen(regen_duration, self)
		return
	# Automatically restart timer
	activity_timer.start()
