extends "object.gd"

@export var compost_duration : int
var composted_dirt : CraftData = load(
	"res://Utilities/Crafting/Crafts/dirt_craft.tres"
)
var compostable_item : ItemData
var compostable_amount : int

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
	else:
		print("Error : No material data available!")
	
	# Setup timer for compost
	activity_timer.timer_finished.connect(_on_compost_ready)
	activity_timer.set_time(compost_duration)
	
# Override
func interact_action(_player: CharacterBody2D) -> void:
	print("Interacting with composter...")
	#CraftingSystem.try_craft(composted_dirt)
	if compost_ready:
		# add dirt to inventory
		inventory.pick_up_slot_data(composted_dirt.slot_data)
		compost_ready = false
	if not activity_timer.is_running():
		add_compost()

	# if any compsting is finished, give player items
	# if no composting is finished, take player items and continue
	# show fill bar of composter when
	# start composting when full
	# add to compost after timer, subtract craft_data.quantity from compostables
	# when player clicks again, add compost to inventory (if possible)
	# start timer to compost items
	# show that the composter is done
	# if composter is done, receive items when interacted with

func add_compost() -> void:
	var leaves_needed: int = inventory.remove_up_to(
		compostable_item, 
		compostable_amount
	)
	# Calculate the percentage that the compost bin is filled
	var percent: float = (
		(float(compostable_amount - leaves_needed) / float(compostable_amount))
		 * 100.0
	)
	# If there's none left to add the composter it is full
	activity_timer.add_value(percent)
	if percent >= 100.0:
		print("Composter is full, starting timer.")
		activity_timer.reset_value()
		activity_timer.start()
	
func _on_compost_ready() -> void:
	compost_ready = true
