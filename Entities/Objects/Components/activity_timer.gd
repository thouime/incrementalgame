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
		var progress = (timer.wait_time - timer.time_left) / timer.wait_time
		add_timer_value(progress)

func snap_to_pixel(value: float) -> float:
	return round(value)

func snap_vector_to_pixel(vec: Vector2) -> Vector2:
	return Vector2(snap_to_pixel(vec.x), snap_to_pixel(vec.y))

func set_position() -> void:
	var parent : Node = get_parent()
	if parent is Node2D:
		var parent_position : Vector2 = get_parent().global_position
		var timer_circle_size : Vector2 = timer_circle.get_rect().size
		var progress_bar_size : Vector2 = progress_bar.get_rect().size
		var progress_bar_offset : int = 15
		
		# Center Horizontally and position above parent
		var timer_circle_new_position : Vector2 = Vector2(
			snap_to_pixel(parent_position.x - timer_circle_size.x / 2),
			snap_to_pixel(parent_position.y - timer_circle_size.y - timer_circle_size.y / 2)
		)		
		var progress_bar_new_position : Vector2 = Vector2(
			snap_to_pixel(parent_position.x - progress_bar_size.x / 2), # Centering progress bar
			snap_to_pixel(parent_position.y - progress_bar_size.y - progress_bar_offset) # Adjusting its position
		)
		
		timer_circle.set_position(timer_circle_new_position)
		progress_bar.set_position(progress_bar_new_position)  # This should set the progress bar's position

func set_value(value: float) -> void:
	progress_bar.value = value
	progress_bar.show()

func add_value(value: float) -> void:
	progress_bar.value += value
	progress_bar.show()

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

func is_running() -> bool:
	if timer.time_left > 0:
		return true
	return false

func add_timer_value(value: float) -> void:
	timer_circle.set_value(value)

func _on_timer_timeout() -> void:
	print("Timer is finished!")
	timer_finished.emit()
	timer_done = true
	timer_circle.hide()
