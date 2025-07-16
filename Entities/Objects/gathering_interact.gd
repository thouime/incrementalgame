class_name  GatheringInteract
extends "object.gd"

const ITEM_FEEDBACK_EFFECT = preload(
	"res://Entities/Objects/Components/ItemFeedbackEffect.tscn"
)

## Time to gather before receiving loot.
@export var gather_time: float = 2.0
## Number of interactions before depletion.
@export var interact_limit: int = 10
## Duration of time before resource regenerates.
@export var regen_duration: float = 60
@export var drop_table : DropTable
@export var max_drop_quantity : int = 3
@export var item_feedback_duration : float = 2
@export var equipment_requirement : SlotData

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var timer: Timer
var current_interacts: int = 0

func _ready() -> void:
	super._ready()
	object_type = "Gathering"
	
	if not drop_table:
		printerr("Drop Table not setup for: ", get_object_name())
		return
	drop_table.setup()

func interact_action(player: CharacterBody2D) -> void:
	start_timer(player)

func start_timer(player: CharacterBody2D) -> void:
	timer = Timer.new()
	add_child(timer)
	timer.wait_time = gather_time
	timer.one_shot = false
	timer.timeout.connect(_on_timer_timeout.bind(player))
	timer.start()

func stop_interact_action(_player: CharacterBody2D) -> void:
	if timer:
		timer.stop()
		timer.queue_free()
		timer = null
		print("Stopped gathering.")

func get_drop(player: CharacterBody2D) -> Dictionary:
	
	if not drop_table:
		printerr("Drop Table not setup for: ", get_object_name())
		return {}
		
	# Attempt to get a random drop from the drop table
	var selected_drop: SlotData = drop_table.get_random_drop()
	var drop_data : Dictionary = {}
	
	if selected_drop:
		# Duplicate so we don't modify the original
		var new_slot_data: SlotData = selected_drop.duplicate() as SlotData
		var texture : Texture = new_slot_data.item_data.texture
		var quantity : int = rng.randi_range(1, max_drop_quantity)

		drop_data = {
			"icon" : texture,
			"quantity" : quantity,
			"duration" : item_feedback_duration
		}
		
		new_slot_data.set_quantity(quantity)
		player.inventory_data.pick_up_slot_data(new_slot_data)
		print("Collected item: ", selected_drop.item_data.name, " x", new_slot_data.quantity)
		return drop_data
	else:
		print("No items to collect from: ", get_object_name())
	return drop_data

func is_gathering() -> bool:
	print("Need to overrite this statement and use activity timer!")
	return false

func _on_timer_timeout(_player: CharacterBody2D) -> void:
	print("Gathering timeout finished")

func _on_gather_timeout() -> void:
	var item_dropped : Dictionary = get_drop(PlayerManager.player)
	if item_dropped:
		var feedback_effect: Node2D = ITEM_FEEDBACK_EFFECT.instantiate()
		self.add_child(feedback_effect)
		feedback_effect.setup(
			item_dropped["icon"], 
			item_dropped["quantity"], 
			true,
			item_dropped["duration"]
		)

	# Reduce the number of times the player can interact with the object
	current_interacts += 1
