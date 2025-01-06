class_name PlayerBuilding
extends State

signal stop_building

@export var idle_state : State
@onready var grid: Control = $Grid

func enter() -> void:
	parent.animated_sprite.animation = idle_animations[parent.direction]
	print("Entered Building State")

func exit() -> void:
	print("Exited Building State")

func handle_event(event_data: Dictionary) -> void:
	if event_data.type == "craft":
		process_craft_event(event_data.data)

func process_input(event: InputEvent) -> State:
	# Check for movement inputs
	# Handle cancel action (e.g., pressing the "cancel" action key)
	if event.is_action_pressed("cancel"):
		stop_building.emit()
		return idle_state
	return null

func process_frame(_delta: float) -> State:
	if grid.is_active():
		print("test")
	# Change to build state
	return null

# Draw a grid that shows where to build objects
func draw_grid() -> void:
	grid.draw_grid()
	grid.update_cursor()
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	grid.build_cursor.visible = true
	grid.visible = true

func stop_building_signal(crafting_system_node : Node) -> void:
	pass

# When building is done, emit a signal to transition to another state
func complete_building() -> void:
	stop_building.emit()
	
func process_craft_event(data) -> void:
	print("Process craft event started!")
	print("Data: ", data)

func _on_stop_building() -> void:
	print("Stopping building...")
