# Incremental Game

extends Node2D

const PICKUP = preload("res://Entities/Item/pickup.tscn")

@onready var player: CharacterBody2D = $Player
@onready var main_world: Node2D = $"."
@onready var hub_menu: Control = $UI/HubMenu
@onready var world: Node2D = $World
@onready var crafting_references : Dictionary = {
	"main" : self,
	"world" : $World,
	"grass_tiles" : $World.get_node("Ground"),
	"boundary_tiles" : $World.get_node("Boundary"),
	"inventory" : PlayerManager.player_inventory,
	"grid" : $Grid,
	"hub_menu" : hub_menu
}
@onready var dungeon_world: Node2D = $"../DungeonWorld"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	# Initialize references in Singletons
	CraftingSystem.set_references(crafting_references)
	GameSaveManager.set_scene($".")
	if not GameSaveManager.load_game():
		new_game.call_deferred()
	player.world = world
	player.main_world = main_world
	player.exit_dungeon.connect(_on_exit_dungeon)
	
	connect_dungeons.call_deferred()
	
func new_game() -> void:
	print("New Game Started")
	var player_spawn : Vector2 = world.get_node("PlayerSpawn").global_position
	player.set_position(player_spawn)

func _on_inventory_interface_drop_slot_data(slot_data: SlotData) -> void:
	var pick_up: Area2D = PICKUP.instantiate()
	pick_up.slot_data = slot_data
	pick_up.position = player.get_drop_position()
	add_child(pick_up)

# Connect dungeon entrances
func connect_dungeons() -> void:
	for dungeon in get_tree().get_nodes_in_group("dungeon_entrance"):
		dungeon.enter_dungeon.connect(_on_click_dungeon)
	
	# If a dungeon menu is closed, disconnect enter dungeon signals
	hub_menu.settings_menu_closed.connect(_on_dungeon_menu_closed)
	
	
func _on_click_dungeon(dungeon_data: DungeonResource) -> void:
	hub_menu.open_dungeon_menu(dungeon_data)
	hub_menu.dungeon_start.connect(_on_enter_dungeon.bind(dungeon_data))

func _on_enter_dungeon(dungeon_data: DungeonResource) -> void:
	hub_menu.close_settings_menu()
	main_world.hide()
	set_dungeon_collisions()
	var dungeon : Node = dungeon_data.dungeon_scene.instantiate()
	if dungeon:
		dungeon_world.add_child(dungeon)
		setup_dungeon(dungeon, dungeon_data)
		move_to_dungeon(dungeon)
	else:
		printerr("Warning: Dungeon Scene not set on ", dungeon_data.name)

	print("Entering Dungeon...")

func setup_dungeon(dungeon: Node, dungeon_data: DungeonResource) -> void:
	dungeon.dungeon_data = dungeon_data
	dungeon.spawn_enemies()
	DungeonManager.set_dungeon(dungeon, dungeon_data)

func move_to_dungeon(dungeon: Node) -> void:
	player.reparent(dungeon)
	connect_ladder_exit(dungeon)
	player.a_star_pathfinding.reset_astar()
	player.a_star_pathfinding.initialize_astar(dungeon)
	player.state_machine._connect_interact_signals()
	player.world_position = player.position
	player.position = dungeon.get_node("PlayerSpawn").position
	player.state_machine.change_state(player.state_machine.dungeon_state)
	player.show()
	
func _on_dungeon_menu_closed() -> void:

	if hub_menu.dungeon_start.is_connected(_on_enter_dungeon):
		hub_menu.dungeon_start.disconnect(_on_enter_dungeon)

func connect_ladder_exit(dungeon: Node2D) -> void:
	
	var ladder_node := dungeon.get_node_or_null("Ladder")
	if not ladder_node:
		return
	if not ladder_node.dungeon_exit.is_connected(_on_exit_dungeon):
		ladder_node.dungeon_exit.connect(_on_exit_dungeon.bind(dungeon))

func _on_exit_dungeon(dungeon: Node2D) -> void:
	
	if dungeon:
		dungeon.hide()
		set_world_collisions()
		player.reparent(main_world)
		player.a_star_pathfinding.reset_astar()
		player.a_star_pathfinding.initialize_astar(world)
		# store player position that was entered from and move them here
		player.position = player.world_position
		player.world_position = world.get_node("PlayerSpawn").position
		main_world.show()
		player.health = 100
	else:
		printerr("Warning: dungeon does not exist!")
	
	print("Exiting Dungeon...")

# Set collisions for dungeon interactions
func set_dungeon_collisions() -> void:
	
	# Disable collisions for the player
	player.set_collision_mask_value(1, false) # Boundaries
	player.set_collision_mask_value(4, false) # Objects
	
	# set dungeon collisions
	player.set_collision_mask_value(5, true) # Walls

# Set collisions for world interactions
func set_world_collisions() -> void:
	player.set_collision_mask_value(1, true) # Boundaries
	player.set_collision_mask_value(4, true) # Objects
	
	player.set_collision_mask_value(5, false) # Walls
	player.set_collision_mask_value(9, false) # Enemies

# Run this code when the game is being closed
func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		GameSaveManager.save_game()
		get_tree().quit() # default behavior
