extends StaticBody2D

@onready var selection: Area2D = $Selection

# Offset for the player to be distanced from the object
var player_offset: float = 0.0

signal interact

func _ready() -> void:
	add_to_group("interactables")
	# Get player offset from object
	_get_offset()
	# Add signals for detecting mouse interaction
	selection.mouse_entered.connect(_on_selection_mouse_entered)
	selection.mouse_exited.connect(_on_selection_mouse_entered)
	selection.input_event.connect(_on_selection_input_event)

# Get an offset for the player to be distanced from the object
func _get_offset() -> void:
	for child in get_children():
		if child is Sprite2D:
			player_offset += child.get_rect().size.x
	player_offset = player_offset / 2 + 10

func focus_object() -> void:
	var object_material: Material = self.material
	if object_material and object_material is ShaderMaterial:
		object_material.set_shader_parameter("focus", 
		not object_material.get_shader_parameter("focus"))

func _on_selection_mouse_entered() -> void:
	focus_object()

func _on_selection_mouse_exited() -> void:
	focus_object()

func _on_selection_input_event(
	_viewport: Node, 
	event: InputEvent, 
	_shape_idx: int
) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			interact.emit(global_position, player_offset, self)
			
# Method to be overriden
func interact_action(_player: CharacterBody2D) -> void:
	print("Interacting with object at:", global_position)

# Method to be overriden
func stop_interact_action(_player: CharacterBody2D) -> void:
	print("Stopping Action")

func _on_interact_signal() -> void:
	print("Interact signal activated")
