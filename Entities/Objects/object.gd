extends StaticBody2D

signal interact

# Offset for the player to be distanced from the object
var player_offset: float = 0.0
var player_generated: bool = false
var object_type: String
var object_name: String
# Unique identifier for the instance of the object (for saving/loading)
var object_id: int

@onready var selection: Area2D = $Selection

func _ready() -> void:
	add_to_group("interactables")
	# Get player offset from object
	_get_offset()
	
	# Add signals for detecting mouse interaction
	selection.mouse_entered.connect(_on_selection_mouse_entered)
	selection.mouse_exited.connect(_on_selection_mouse_exited)
	selection.input_event.connect(_on_selection_input_event)
	
	# Add to persist group for saving
	add_to_group("Persist")

# Get an offset for the player to be distanced from the object
func _get_offset() -> void:
	for child in get_children():
		if child is Sprite2D:
			player_offset += child.get_rect().size.x
	player_offset = player_offset / 2 + 10

func get_player_generated() -> bool:
	return player_generated

func get_object_type() -> String:
	return object_type

func set_object_type(type: String) -> void:
	object_type = type

func get_object_name() -> String:
	return object_name

func set_object_name(new_name: String) -> void:
	object_name = new_name

func focus_shader(focus_state: int) -> void:
	# Prevent hover shaders while in building state
	if PlayerManager.player_state is PlayerBuilding:
		return
	draw_shader(focus_state)
	
func draw_shader(focus_state: int) -> void:
	var object_material: Material = self.material
	if object_material and object_material is ShaderMaterial:
		object_material.set_shader_parameter("focus", focus_state)

func _on_selection_mouse_entered() -> void:
	focus_shader(true)

func _on_selection_mouse_exited() -> void:
	focus_shader(false)

func _on_selection_input_event(
	_viewport: Node, 
	event: InputEvent, 
	_shape_idx: int
) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			interact.emit(global_position, player_offset, self)

# Function to be overriden for objects that have gathering
func is_gathering() -> bool:
	return false

# Method to be overriden
func interact_action(_player: CharacterBody2D) -> void:
	print("Interacting with object at:", global_position)

# Method to be overriden
func stop_interact_action(_player: CharacterBody2D) -> void:
	print("Stopping Action")

func _on_interact_signal() -> void:
	print("Interact signal activated")
