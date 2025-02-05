class_name PlayerCrafting
extends State

@export var idle_state : State
@onready var grid: Control = $Grid
@onready var player_inventory: InventoryData
@onready var crafter: Node = $Crafter

enum CraftType { CRAFT, BUILD}

func enter() -> void:
	parent.animated_sprite.animation = idle_animations[parent.direction]
	player_inventory = PlayerManager.player_inventory
	print("Entered Building State")

func exit() -> void:
	player_inventory = null
	print("Exited Building State")

func handle_event(event_data: Dictionary) -> void:
	# Crafting items simply adds the item to the inventory
	# No additional steps are necessary
	match event_data.type:
		"craft":
			process_craft_event(event_data.data)
		"build":
			print("test")
		_:
			print("Unknown event data type during crafting!")

func process_input(event: InputEvent) -> State:
	# Check for movement inputs
	# Handle cancel action (e.g., pressing the "cancel" action key)
	if event.is_action_pressed("cancel"):
		stop_crafting()
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

# Emit a signal that the state machine handles to cleanly change states
func stop_crafting() -> void:
	Transitioned.emit(idle_state)
	
func process_craft_event(craft_data: CraftData) -> void:
	print("Process craft event started!")
	# Check if we can craft the item
	if not crafter.can_craft(craft_data, player_inventory):
		stop_crafting()
		return
	crafter.craft(craft_data, player_inventory)
	stop_crafting()
	
