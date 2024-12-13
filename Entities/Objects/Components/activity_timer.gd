extends Node
class_name ActivityTimer

signal timer_finished

var timer_done : bool = false

@onready var progress_bar: ProgressBar = $ProgressBar
@onready var timer: Timer = $Timer
@onready var color_rect: ColorRect = $ColorRect

func _ready() -> void:
	progress_bar.hide()
	setup_timer()
	set_position()

func snap_to_pixel(value: float) -> float:
	return round(value)

func snap_vector_to_pixel(vec: Vector2) -> Vector2:
	return Vector2(snap_to_pixel(vec.x), snap_to_pixel(vec.y))

func set_position() -> void:
	var parent : Node = get_parent()
	if parent is Node2D:
		var parent_position : Vector2 = get_parent().global_position
		var color_rect_size : Vector2 = color_rect.get_rect().size
		
		# Center Horizontally and position above parent
		var new_position : Vector2 = Vector2(
			snap_to_pixel(parent_position.x - color_rect_size.x / 2),
			snap_to_pixel(parent_position.y - color_rect_size.y - color_rect_size.y / 2)
		)
		
		color_rect.set_position(new_position)

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

func is_running() -> bool:
	if timer.time_left > 0:
		return true
	return false

func _on_timer_timeout() -> void:
	print("Timer is finished!")
	timer_finished.emit()
	timer_done = true
