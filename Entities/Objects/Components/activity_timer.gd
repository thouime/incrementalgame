extends Node 
class_name ActivityTimer

signal timer_finished

var timer_done : bool = false

@onready var progress_bar: ProgressBar = $ProgressBar
@onready var timer: Timer = $Timer
@onready var timer_circle: ColorRect = $TimerCircle

func _ready() -> void:
	progress_bar.hide()
	setup_timer()
	set_position()

func _process(_delta: float) -> void:
	if is_running():
		var progress: float = (timer.wait_time - timer.time_left) / timer.wait_time
		add_timer_value(progress)

func set_position() -> void:
	var parent : Node = get_parent()
	var object_position := Vector2(parent.position)
	if parent is Node2D:
		# Calculate the combined height of each sprite
		var combined_height : float
		for child in parent.get_children():
			if child is Sprite2D:
				var sprite_height := float(child.get_rect().size.y)
				combined_height = combined_height + sprite_height
		
		# Calculate new positions
		var timer_circle_size : Vector2 = timer_circle.get_rect().size
		var progress_bar_size : Vector2 = progress_bar.get_rect().size
		var padding : float = 12
		
		var timer_circle_new_position := Vector2(
			object_position.x - timer_circle_size.x / 2,
			object_position.y - combined_height / 2  
				- timer_circle_size.y 
				- padding
		)
		
		var progress_bar_new_position : Vector2 = Vector2(
			object_position.x - progress_bar_size.x / 2,
			object_position.y - combined_height / 2 
				- progress_bar_size.y 
				- padding
		)

		timer_circle.set_position(timer_circle_new_position)
		progress_bar.set_position(progress_bar_new_position)
		
func set_progress_value(value: float) -> void:
	progress_bar.value = value
	progress_bar.show()

func add_progress_value(value: float) -> void:
	progress_bar.value += value
	progress_bar.show()

func get_progress_value() -> float:
	return progress_bar.value

func reset_value() -> void:
	progress_bar.value = 0
	progress_bar.hide()
	
func setup_timer() -> void: 
	timer.wait_time = 5 # Default time
	timer.one_shot = true
	timer.timeout.connect(_on_timer_timeout)
	
func set_time(duration: float) -> void:
	timer.wait_time = duration

func start() -> void:
	timer.start()
	timer_done = false
	timer_circle.show()

func stop() -> void:
	timer_done = true
	timer_circle.hide()
	timer.stop()

func end() -> void:
	timer_done = true
	timer_circle.hide()
	timer_finished.emit()

func is_running() -> bool:
	return timer.time_left > 0

func add_timer_value(value: float) -> void:
	timer_circle.set_value(value)

func _on_timer_timeout() -> void:
	end()
	print("Timer is finished!")
