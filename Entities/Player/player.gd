class_name Player 
extends CharacterBody2D

signal toggle_inventory()
#enum State { IDLE, MOVING, GATHERING }
@export var player_speed: int = 400
@export var inventory_data: InventoryData
@export var equip_inventory_data: InventoryDataEquip
#var state = State.IDLE
var screen_size : Vector2
var player_size : Vector2
var sprite_offset : Vector2 = Vector2(144, 144)
var direction: Vector2 = Vector2.UP
var health : int = 5
var target_position : Vector2 = Vector2.ZERO
var interact_target : Node = null
@onready var animated_sprite : AnimatedSprite2D = $AnimatedSprite2D
@onready var camera : Camera2D = $Camera2D
@onready var interact_ray : RayCast2D = $Camera2D/InteractRay
@onready var state_machine : Node = $StateMachine

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	PlayerManager.player = self
	PlayerManager.player_inventory = inventory_data
	PlayerManager.state_machine = state_machine
	screen_size = get_viewport_rect().size
	set_animation()
	state_machine.init(self, CraftingSystem)
	
# Sprite and Animations
func set_animation() -> void:
	var current_animation : String = animated_sprite.animation
	var current_frame : int = animated_sprite.frame
	var sprite_frames : SpriteFrames = animated_sprite.sprite_frames
	var player_texture : Texture2D = sprite_frames.get_frame_texture(
		current_animation, 
		current_frame
	)
	var sprite_size : Vector2 = player_texture.get_size()
	player_size = sprite_size - sprite_offset
	animated_sprite.play()

func _unhandled_input(event: InputEvent) -> void:
	state_machine.process_input(event)
	
func _physics_process(delta: float) -> void:
	state_machine.process_physics(delta)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Non movement inputs
	if Input.is_action_just_pressed("inventory"):
		toggle_inventory.emit()
	if Input.is_action_just_pressed("interact"):
		interact()
	if Input.is_action_just_pressed("toggle_menu"):
		print("Toggle Menu")

	
	state_machine.process_frame(delta)

func any_menu_is_open() -> bool:
	return false
	
func close_all_menus() -> void:
	pass
	
func toggle_escape_menu() -> void:
	pass
		
func interact() -> void:
	if interact_ray.is_colliding():
		var collider : Object = interact_ray.get_collider()
		# Check if collider has player_interact method, if not there may be a custom area
		# that's a child of the parent. Therefore, check the parent instead.
		if collider:
			var parent : Node = collider.get_parent()
			if collider.has_method("player_interact"):
				collider.player_interact()
			elif parent.has_method("player_interact"):
				parent.player_interact()
			else:
				print("Object doesn't have player_interact method.")

func get_drop_position() -> Vector2:
	var player_position : Vector2 = self.global_position
	var drop_direction : Vector2 = direction.normalized()
	var offset_distance : int = 40
	var drop_position : Vector2 = player_position + drop_direction * offset_distance
	drop_position.y += 12
	return drop_position

func heal(heal_value: int) -> void:
	health += heal_value
