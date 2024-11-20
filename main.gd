extends Node

const PICKUP = preload("res://Entities/Item/pickup.tscn")

@onready var player: CharacterBody2D = $Player
@onready var inventory_interface: Control = $UI/InventoryInterface
@onready var hot_bar_inventory: PanelContainer = $UI/HotBarInventory

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	inventory_interface.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# Inventory Setup
	player.toggle_inventory.connect(toggle_inventory_interface)
	inventory_interface.set_player_inventory_data(player.inventory_data)
	inventory_interface.set_equip_inventory_data(player.equip_inventory_data)
	inventory_interface.force_close.connect(toggle_inventory_interface)
	hot_bar_inventory.set_inventory_data(player.inventory_data)
	
	for node in get_tree().get_nodes_in_group("external_inventory"):
		node.toggle_inventory.connect(toggle_inventory_interface)

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

func toggle_inventory_interface(external_inventory_owner: Node = null) -> void:
	# Check if opening or closing player inventory
	if external_inventory_owner:
		# Always set the external inventory if it's provided
		inventory_interface.set_external_inventory(external_inventory_owner)
		inventory_interface.visible = true  # Ensure it opens if interacting with external
	else:
		# Toggle only the player's inventory visibility
		inventory_interface.visible = not inventory_interface.visible
		# Clear any external inventory if closing or only showing player inventory
		if not inventory_interface.visible:
			inventory_interface.clear_external_inventory()
	
	# Handle the hot bar based on visibility
	if inventory_interface.visible:
		hot_bar_inventory.hide()
	else:
		hot_bar_inventory.show()


func toggle_external_inventory(external_inventory_owner: Node) -> void:
	if external_inventory_owner and inventory_interface.visible:
		inventory_interface.set_external_inventory(external_inventory_owner)
	else:
		inventory_interface.clear_external_inventory()

func _on_inventory_interface_drop_slot_data(slot_data: SlotData) -> void:
	var pick_up: Area2D = PICKUP.instantiate()
	pick_up.slot_data = slot_data
	pick_up.position = player.get_drop_position()
	add_child(pick_up)
