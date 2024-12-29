extends "object.gd"

const ITEM_FEEDBACK_EFFECT = preload("res://Entities/Objects/Components/ItemFeedbackEffect.tscn")

@export var compost_duration : int
@export var dirt_received : int = 1
var composted_dirt : CraftData = preload(
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
		var new_slot_data = composted_dirt.slot_data.duplicate() as SlotData
		inventory.pick_up_slot_data(new_slot_data)
		add_item_effect(new_slot_data.item_data.texture, dirt_received, true)
		compost_ready = false

func add_compost() -> void:
	# If there's nothing to compost, no need to check anything else
	if inventory.check_total(compostable_item) <= 0:
		return
	
	# Check how many leaves are needed to fill the compost bin
	leaves_needed = inventory.remove_up_to(
		compostable_item, 
		leaves_needed
	)
	var leaves_removed: int = compostable_amount - leaves_needed
	add_item_effect(compostable_item.texture, leaves_removed, false)
	# Calculate the percentage that the compost bin is filled
	var percent: float = (
		(float(leaves_removed) / float(compostable_amount))
		 * 100.0
	)
	
	activity_timer.set_progress_value(percent)
	var progress: float = activity_timer.get_progress_value()
	if progress >= 100.0:
		print("Composter is full, starting timer.")
		activity_timer.reset_value()
		activity_timer.start()

func add_item_effect(icon: Texture, quantity: int, is_gain: bool) -> void:
	var feedback_effect: Node2D = ITEM_FEEDBACK_EFFECT.instantiate()
	self.add_child(feedback_effect)
	feedback_effect.setup(
		icon,
		quantity,
		is_gain
	)

func _on_compost_ready() -> void:
	compost_ready = true
	leaves_needed = compostable_amount
