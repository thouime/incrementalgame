class_name Player 
extends CharacterBody2D

signal toggle_inventory()
signal death
signal exit_dungeon

#enum State { IDLE, MOVING, GATHERING }
@export var player_speed: int = 400
@export var inventory_data: InventoryData
@export var equip_inventory_data: InventoryDataEquip
@export var chase_range : float
@export var attack_range : float
@export var attack_speed : float
@export var attack_power : float

var screen_size : Vector2
var player_size : Vector2
var sprite_offset : Vector2 = Vector2(144, 144)
var direction: Vector2 = Vector2.UP
var health : int = 100
var attack_bonus : int = 0
var target_position : Vector2 = Vector2.ZERO
var interact_target : Node = null
var placed_tiles : Dictionary
var main_world : Node2D
var world : Node2D
var world_position : Vector2
@onready var animated_sprite : AnimatedSprite2D = $AnimatedSprite2D
@onready var camera : Camera2D = $Camera2D
@onready var interact_ray : RayCast2D = $Camera2D/InteractRay
@onready var state_machine : Node = $StateMachine
@onready var a_star_pathfinding: Node = $AStarPathfinding
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	PlayerManager.player = self
	PlayerManager.player_inventory = inventory_data
	PlayerManager.player_equipment = equip_inventory_data
	PlayerManager.state_machine = state_machine
	screen_size = get_viewport_rect().size
	set_animation()
	state_machine.init(self, CraftingSystem)
	start_a_star.call_deferred()
	death.connect(_on_death)
	
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

func start_a_star() -> void:
	a_star_pathfinding.initialize_astar(world)

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

	state_machine.process_frame(delta)
	
	# Add elapsed time every frame
	PlayerManager.time_played += delta

func any_menu_is_open() -> bool:
	return false
	
func close_all_menus() -> void:
	pass
	
func toggle_escape_menu() -> void:
	pass
		
func interact() -> void:
	if interact_ray.is_colliding():
		var collider : Object = interact_ray.get_collider()
		# Check if collider has player_interact method, 
		# if not there may be a custom area
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

func take_damage(damage: int) -> void:
	print("Player took damage!")
	health -= damage
	print("Current Health: ", health)
	if health <= 0:
		death.emit()

func _on_death() -> void:
	print("The player is dead!")
	
	animated_sprite.play("death")
	
	# Wait time before exiting dungeon in seconds
	var death_timer := 2
	
	await get_tree().create_timer(death_timer).timeout
	
	after_death()
	

func after_death() -> void:
	print("Death animation finished")
	
	if DungeonManager.current_dungeon:
		exit_dungeon.emit(DungeonManager.current_dungeon)
	
	state_machine.change_state(state_machine.initial_state)
	
	# Death animation doesn't loop, so restart animation
	animated_sprite.play()

# Check for collisions at the given point and collision mask
func intersect_point(pos: Vector2, mask: int) -> Node2D:
	var space_state: PhysicsDirectSpaceState2D = get_world_2d().direct_space_state
	var query: PhysicsPointQueryParameters2D = PhysicsPointQueryParameters2D.new()
	query.position = pos
	query.collide_with_areas = true
	query.collide_with_bodies = true
	query.collision_mask = mask
	
	var results: Array[Dictionary] = space_state.intersect_point(query, 32)
	
	for result: Dictionary in results:
		var collider: Object = result["collider"]
		if collider is Node2D and is_in_group_recursive(collider as Node, "interactables"):
			return collider as Node2D

	return null

func is_in_group_recursive(node: Node, group: String) -> bool:
	while node:
		if node.is_in_group(group):
			return true
		node = node.get_parent()
	return false

func add_bonus_attack(attack: int) -> void:
	attack_bonus += attack

func get_attack_damage() -> int:
	var total_attack := attack_power + attack_bonus
	var min_damage := int(total_attack * 0.8)
	var max_damage := int(total_attack * 1.2)
	return randi_range(min_damage, max_damage)
