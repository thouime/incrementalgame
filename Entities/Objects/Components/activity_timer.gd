extends Node2D
class_name ActivityTimer

signal timer_finished
signal regen_finished

var timer_done : bool = false
var regen_complete : bool = true

@onready var progress_bar: ProgressBar = $ProgressBar
@onready var timer: Timer = $Timer
@onready var timer_circle: ColorRect = $TimerCircle
@onready var regen_timer: Timer = $RegenTimer

func _ready() -> void:
	progress_bar.hide()
	setup_timer()
	set_new_position()

func _process(_delta: float) -> void:
	if is_running():
		var progress: float = (timer.wait_time - timer.time_left) / timer.wait_time
		add_timer_value(progress)

func set_new_position() -> void:
	var parent : Node = get_parent()
	if parent is Node2D:
		# Calculate the combined height of each sprite
		var combined_height : float
		var width : float
		for child in parent.get_children():
			if child is Sprite2D:
				var sprite_height := float(child.get_rect().size.y)
				combined_height = combined_height + sprite_height
				if not width:
					width = float(child.get_rect().size.x)
		
		# Calculate new positions
		var timer_circle_size : Vector2 = timer_circle.get_rect().size
		var padding : float = 4
		
		# Center the timer circle horizontally above the parent object 
		var timer_circle_new_position := Vector2(
			- timer_circle_size.x / 2, 
			- padding - timer_circle_size.y - combined_height / 2
		)
		
		# Position the progress bar below the timer circle
		var progress_bar_new_position := Vector2(
			- width / 2, 
			- timer_circle_size.y - combined_height / 2
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

func set_regen_time(duration: float) -> void:
	regen_timer.wait_time = duration
	regen_timer.one_shot = true
	regen_timer.timeout.connect(_on_timer_timeout)

func start_regen() -> void:
	regen_complete = false
	regen_timer.start()

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
