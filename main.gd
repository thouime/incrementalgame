# Incremental Game

extends Node

const PICKUP = preload("res://Entities/Item/pickup.tscn")

@onready var player: CharacterBody2D = $Player
@onready var hub_menu: Control = $UI/HubMenu
@onready var inventory_interface: Control = $UI/InventoryInterface
@onready var hot_bar_inventory: PanelContainer = $UI/HotBarInventory
@onready var crafting_menu: PanelContainer = $UI/CraftingMenu
@onready var world: Node2D = $World
@onready var crafting_references : Dictionary = {
	"main" : self,
	"world" : $World,
	"grass_tiles" : $World.get_node("Grass"),
	"boundary_tiles" : $World.get_node("Boundary"),
	"inventory" : PlayerManager.player_inventory,
	"grid" : $Grid,
	"hub_menu" : hub_menu
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	# Initialize references in Singletons
	CraftingSystem.set_references(crafting_references)
	GameSaveManager.set_scene(get_tree().current_scene)
	GameSaveManager.load_game()
	crafting_menu.craft_item_request.connect(CraftingSystem.try_craft)
	player.world = world

func update_label(label: Label, material: int) -> void:
	# Split the label text into prefix and current value
	var label_text: Array[String] = label.text.split(": ")
	if label_text.size() > 1:
		var prefix: String = label_text[0]
		label.text = prefix + ": "+ str(material)

func create_timer(duration: int, _on_timeout: Callable) -> Timer:
	var timer: Timer = Timer.new()
	timer.wait_time = duration
	timer.autostart = false
	timer.one_shot = false
	add_child(timer)
	timer.timeout.connect(_on_timeout)
	return timer

func _on_inventory_interface_drop_slot_data(slot_data: SlotData) -> void:
	var pick_up: Area2D = PICKUP.instantiate()
	pick_up.slot_data = slot_data
	pick_up.position = player.get_drop_position()
	add_child(pick_up)

# Run this code when the game is being closed
func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		GameSaveManager.save_game()
		get_tree().quit() # default behavior
