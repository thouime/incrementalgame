extends "res://Entities/Objects/object.gd"

signal toggle_inventory(external_inventory_owner: Node)

## Rotation speed of sprite (default float: 50)
@export var rotation_speed : float = 50
## Speed of harvester (float)
@export var gather_time : float = 5.0
## Size of inventory
@export var internal_buffer : int = 10

@export var inventory_data: InventoryData

var gathering_object : Node2D

func _ready() -> void:
	super._ready()
	initialize()
	inventory_data = InventoryData.new()
	inventory_data.initialize_slots(3)
	add_to_group("external_inventory")
	setup_automation()

# Handles the rotation of the sprite (rotating gear) to give feedback
func _physics_process(delta: float) -> void:
	rotation_degrees += rotation_speed * delta
	if rotation_degrees >= 360:
		rotation_degrees = 0

func initialize() -> void:
	set_object_type("automation")
	set_object_name("harvester")

# Open inventory instead of normal gathering interaction
func interact_action(_player: CharacterBody2D) -> void:
	toggle_inventory.emit(self)

func setup_automation() -> void:
	if not gathering_object:
		printerr("No gathering object found for harvester!")
		return
	var activity_timer : ActivityTimer = (
		gathering_object.get_node_or_null("ActivityTimer")
	)
	# Update the gather time to be the harvester gather time
	if activity_timer:
		activity_timer.set_time(gather_time)
		activity_timer.start()
		# Restart the timer automatically after object regenerates
		activity_timer.regen_timer.timeout.connect(activity_timer.start)


func add_item(slot_data: SlotData, connector : Node2D = null) -> void:
	inventory_data.pick_up_slot_data(slot_data)
	
	if not connector:
		return
		
	if not connector.has_method("transfer_items"):
		return
			
	connector.transfer_items(inventory_data)
	# add to buffer
	# buffer checks for external inventory then adds
	
# check if there is a connected inventory
# if not connected inventory, do next check
# if connected inventory, send to inventory
# if buffer is full, stop, end rotation of gear
# load object correctly instead of like a regular object
