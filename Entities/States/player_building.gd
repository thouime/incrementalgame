class_name PlayerBuilding
extends State

signal stop_building

@export var idle_state : State
var done_building : bool = false

func enter() -> void:
	parent.animated_sprite.animation = idle_animations[parent.direction]
	print("Entered Building State")
	
func exit() -> void:
	print("Exited Building State")

func process_input(event: InputEvent) -> State:
	# Check for movement inputs
	# Handle cancel action (e.g., pressing the "cancel" action key)
	if event.is_action_pressed("cancel"):
		stop_building.emit()
		return idle_state
	return null

func process_frame(delta: float) -> State:
	# Change to build state
	if done_building:
		done_building = false
		return idle_state
	return null

func set_signal(crafting_menu):
	stop_building.connect(crafting_menu._on_stop_building)
	crafting_menu.connect("stop_building", _on_stop_building)

func _on_stop_building() -> void:
	done_building = true
	print("Stop building")
