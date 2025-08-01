extends "res://Entities/Objects/object.gd"

@export var transfer_speed : float = 5 # in seconds
@export var transfer_quantity : int = 5

var source_object : Node2D
var target_object : Node2D

@onready var source_sprite: Sprite2D = $SourceSprite
@onready var target_sprite: Sprite2D = $TargetSprite
@onready var transfer_timer: Timer = $TransferTimer

# Draw a line between the two objects

func _ready() -> void:
	super._ready()
	initialize()
	source_sprite.show()
	target_sprite.show()
	transfer_timer.wait_time = transfer_speed
	set_indicators()

func initialize() -> void:
	set_object_type("automation")
	set_object_name("connector")
	
func set_indicators() -> void:
	var vertical_offset : float = 30
	var source_pos : Vector2 = source_object.global_position
	var target_pos : Vector2 = target_object.global_position
	source_pos.y -= vertical_offset
	target_pos.y -= vertical_offset
	source_sprite.position = source_pos
	target_sprite.position = target_pos

func transfer_items(inventory: InventoryData) -> void:
	
	if not transfer_timer.timeout.is_connected(_on_transfer_timeout):
		transfer_timer.timeout.connect(_on_transfer_timeout.bind(inventory))
	
	if transfer_timer.is_stopped():
		transfer_timer.start()

func _on_transfer_timeout(inventory: InventoryData) -> void:
	var current_quantity : int = transfer_quantity
	var slot_data : SlotData = inventory.get_first_item()
	if not slot_data:
		return
	var new_slot_data: SlotData = slot_data.duplicate() as SlotData
	var target_inventory : InventoryData = target_object.inventory_data
#	might need to duplicate slot_data before removing
	if slot_data.quantity < transfer_quantity:
		current_quantity = slot_data.quantity
	if not target_inventory:
		printerr("Target doesn't have an inventory!")
	if slot_data:
		inventory.reduce_slot_amount(slot_data.item_data, current_quantity)
		new_slot_data.set_quantity(current_quantity)
		target_inventory.pick_up_slot_data(new_slot_data)
		# get the next item
		slot_data = inventory.get_first_item()
	if slot_data:
		transfer_timer.start()
