extends "res://Entities/Objects/object.gd"

@export var compost_duration : int
var composted_dirt : CraftData = load(
	"res://Utilities/Crafting/Crafts/dirt_craft.tres"
)
var compostable_item : ItemData
var compostable_amount : int
var leaves_needed : int # Leaves needed to fill the compost bin

var compost_ready : bool = false
@onready var inventory : InventoryData = PlayerManager.player_inventory
@onready var activity_timer: ActivityTimer = $ActivityTimer

func _ready() -> void:
	super._ready()
	# Set the compostable item to the first item in the material slot datas
	# This is just the required items needed for a craft, in this case only 1
	if composted_dirt.material_slot_datas.size() > 0:
		compostable_item = composted_dirt.material_slot_datas[0].item_data
		compostable_amount = composted_dirt.material_slot_datas[0].quantity
		leaves_needed = compostable_amount
	else:
		print("Error : No material data available!")
	
	# Setup timer for compost
	activity_timer.timer_finished.connect(_on_compost_ready)
	activity_timer.set_time(compost_duration)
	
# Override
func interact_action(_player: CharacterBody2D) -> void:
	print("Interacting with composter...")
	#CraftingSystem.try_craft(composted_dirt)
	if not activity_timer.is_running() and not compost_ready:
		add_compost()
	if compost_ready:
		# Add dirt to inventory
		# Duplicate so we don't modify the original
		var new_slot_data: SlotData = composted_dirt.slot_data.duplicate() as SlotData
		inventory.pick_up_slot_data(new_slot_data)
		compost_ready = false

func add_compost() -> void:

	leaves_needed = inventory.remove_up_to(
		compostable_item, 
		leaves_needed
	)
	
	# Calculate the percentage that the compost bin is filled
	var percent: float = (
		(float(compostable_amount - leaves_needed) / float(compostable_amount))
		 * 100.0
	)
	activity_timer.add_progress_value(percent)
	var progress: float = activity_timer.get_progress_value()
	if progress >= 100.0:
		print("Composter is full, starting timer.")
		activity_timer.reset_value()
		activity_timer.start()
	
func _on_compost_ready() -> void:
	compost_ready = true
	leaves_needed = compostable_amount
