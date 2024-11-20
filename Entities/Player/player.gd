extends CharacterBody2D

@export var player_speed: int = 400
@export var inventory_data: InventoryData
@export var equip_inventory_data: InventoryDataEquip

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var interact_ray: RayCast2D = $Camera2D/InteractRay
@onready var camera: Camera2D = $Camera2D

var screen_size: Vector2
var player_size: Vector2
var sprite_offset: Vector2 = Vector2(144, 144)
var last_direction: Vector2 = Vector2(0, -1) # Face up by default
var health: int = 5
var target_position: Vector2 = Vector2.ZERO
var interact_target: Node = null

signal toggle_inventory()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	PlayerManager.player = self
	PlayerManager.player_inventory = inventory_data
	PlayerManager.state = PlayerManager.State.IDLE
	screen_size = get_viewport_rect().size
	set_animation()
	
	# Connect interactables after all the nodes are added ot the scene
	call_deferred("_connect_interact_signals")
	
# Sprite and Animations
func set_animation() -> void:
	var current_animation: String = animated_sprite.animation
	var current_frame: int = animated_sprite.frame
	var sprite_frames: SpriteFrames = animated_sprite.sprite_frames
	var player_texture: Texture = sprite_frames.get_frame_texture(current_animation, current_frame)
	var sprite_size: Vector2 = player_texture.get_size()
	player_size = sprite_size - sprite_offset
	animated_sprite.play()

func _connect_interact_signals() -> void:
	# Connect signal for all interactable objects
	for node in get_tree().get_nodes_in_group("interactables"):
		node.connect("interact", _on_interact_signal)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Handle key movement and moving to objects
	handle_movement(delta)
	
	# Non movement inputs
	if Input.is_action_just_pressed("inventory"):
		toggle_inventory.emit()
	if Input.is_action_just_pressed("interact"):
		interact()
	if Input.is_action_just_pressed("toggle_menu"):
		print("Toggle Menu")
		# Check if no menus are open
		# Check if grid is open
		# If there's nothing to cancel or close, open the menu

func any_menu_is_open() -> bool:
	return false
	
func close_all_menus() -> void:
	pass
	
func toggle_escape_menu() -> void:
	pass

func handle_movement(delta: float) -> void:
	var player_velocity: Vector2 = Vector2.ZERO
	var directions: Dictionary = {
		"move_right": Vector2.RIGHT,
		"move_left": Vector2.LEFT,
		"move_down": Vector2.DOWN,
		"move_up": Vector2.UP
	}
	var animations: Dictionary = {
		Vector2.RIGHT: "walk_right",
		Vector2.LEFT: "walk_left",
		Vector2.DOWN: "walk_down",
		Vector2.UP: "walk_up"
	}
	var idle_animations: Dictionary = {
		Vector2.RIGHT: "idle_right",
		Vector2.LEFT: "idle_left",
		Vector2.DOWN: "idle_down",
		Vector2.UP: "idle_up"
	}
	player_velocity = handle_key_movement(delta, directions)
	if PlayerManager.state == PlayerManager.State.MOVING:
		player_velocity = move_towards_target(delta)
	# Normalize player_velocity and move the player
	if player_velocity.length() > 0:
		# Set movement animations
		animated_sprite.animation = animations[last_direction]
		
		# Flip the sprite if facing left
		if player_velocity.x != 0:
			animated_sprite.flip_h = player_velocity.x < 0
			
		# Start movement
		player_velocity = player_velocity.normalized() * player_speed
		position += player_velocity * delta
		move_and_slide()
		
		# Set RayCast2D target position based on the player's size and direction
		interact_ray.target_position = last_direction * 35 # Set the ray length to 100 pixels
		
	elif PlayerManager.state == PlayerManager.State.GATHERING:
		# Face up at the object
		animated_sprite.animation = idle_animations[Vector2.UP]
	elif PlayerManager.state == PlayerManager.State.IDLE:
		animated_sprite.animation = idle_animations[last_direction]

func handle_key_movement(_delta: float, directions: Dictionary) -> Vector2:
	var player_velocity: Vector2 = Vector2.ZERO
	# Check for movement inputs
	for action: String in directions.keys():
		if Input.is_action_pressed(action):
			# Get direction based on the key pressed
			var direction: Vector2 = directions[action]
			player_velocity += direction
			last_direction = direction
			
			# Interrupt player gathering
			if PlayerManager.state == PlayerManager.State.GATHERING and interact_target:
				interact_target.stop_interact_action(self)
				
			# Set state to idle to interrupt other movement actions, reset interact_target
			PlayerManager.state = PlayerManager.State.IDLE
			interact_target = null
	return player_velocity

func move_towards_target(delta: float) -> Vector2:
	# Calculate the direction vector to the target position
	var direction: Vector2 = (target_position - global_position).normalized()
	# Get the animation direction based on which is closest to the object
	last_direction = get_closest_direction(direction)
	
	# Calculate the player_velocity
	var player_velocity: Vector2 = direction * player_speed

	# Start gathering if the player is close to the object
	if global_position.distance_to(target_position) <= 10:
		PlayerManager.state = PlayerManager.State.GATHERING
		gather_from_target(delta)
		player_velocity = Vector2.ZERO
	
	return player_velocity

func get_closest_direction(direction: Vector2) -> Vector2:
	# Calculate dot products with each main direction
	var dot_right: float = direction.dot(Vector2.RIGHT)
	var dot_left: float = direction.dot(Vector2.LEFT)
	var dot_up: float = direction.dot(Vector2.UP)
	var dot_down: float = direction.dot(Vector2.DOWN)

	# Determine which direction has the highest dot product (most aligned)
	var max_dot: float = max(dot_right, dot_left, dot_up, dot_down)

	# Set default priority order for cases where directions are equally close
	if max_dot == dot_right:
		return Vector2.RIGHT
	elif max_dot == dot_left:
		return Vector2.LEFT
	elif max_dot == dot_up:
		return Vector2.UP
	else:
		return Vector2.DOWN

func gather_from_target(_delta: float) -> void:
	# Gather animation
	if interact_target:
		interact_target.interact_action(self)
		
func interact() -> void:
	if interact_ray.is_colliding():
		var collider: Area2D = interact_ray.get_collider()
		# Check if collider has player_interact method, if not there may be a custom area
		# that's a child of the parent. Therefore, check the parent instead.
		if collider:
			var parent: StaticBody2D = collider.get_parent()
			if collider.has_method("player_interact"):
				collider.player_interact()
			elif parent.has_method("player_interact"):
				parent.player_interact()
			else:
				print("Object doesn't have player_interact method.")

func get_drop_position() -> Vector2:
	var player_position: Vector2 = self.global_position
	var direction: Vector2 = last_direction.normalized()
	var offset_distance: int = 40
	var drop_position: Vector2 = player_position + direction * offset_distance
	drop_position.y += 12
	return drop_position

func heal(heal_value: int) -> void:
	health += heal_value

func _on_interact_signal(pos: Vector2, offset: float, object: StaticBody2D) -> void:
	# Check if they are already interacting with the same object
	if not object == interact_target:
		# Interrupt player if they are already gathering
		if PlayerManager.state == PlayerManager.State.GATHERING and interact_target:
			interact_target.stop_interact_action(self)
		target_position = pos
		# Target underneath the object so player is in the front
		target_position.y += offset
		PlayerManager.state = PlayerManager.State.MOVING

		print("Player is moving towards: ", target_position)
		interact_target = object # Store the interact target
