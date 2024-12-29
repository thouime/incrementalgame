extends "res://Entities/Objects/gathering_interact.gd"

const ITEM_FEEDBACK_EFFECT = preload("res://Entities/Objects/Components/ItemFeedbackEffect.tscn")

@export var drop_table : DropTable
@export var max_drop_quantity : int = 3
@export var item_feedback_duration : float = 2

var rng: RandomNumberGenerator = RandomNumberGenerator.new()

@onready var activity_timer: ActivityTimer = $ActivityTimer

func _ready() -> void:
	super._ready()
	# Initialize all the drops added from the editor
	drop_table.setup()
	
	activity_timer.timer_finished.connect(_on_gather_timeout)
	activity_timer.set_time(gather_time)

# Override
func interact_action(_player: CharacterBody2D) -> void:
	# Specific bush logic
	activity_timer.start()
	print("Gathering from bush...")

func stop_interact_action(_player: CharacterBody2D) -> void:
	activity_timer.stop()

func get_drop(player: CharacterBody2D) -> Dictionary:
	# Attempt to get a random drop from the drop table
	var selected_drop: SlotData = drop_table.get_random_drop()
	var drop_data : Dictionary = {}
	if selected_drop:
		# Duplicate so we don't modify the original
		var new_slot_data: SlotData = selected_drop.duplicate() as SlotData
		var texture : Texture = new_slot_data.item_data.texture
		var quantity : int = rng.randi_range(1, max_drop_quantity)  # Set random quantity if needed

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
		print("No items to collect from the bush.")
	return drop_data

func _on_timer_timeout(_player: CharacterBody2D) -> void:
	pass
		
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
	activity_timer.start()
