extends "res://Entities/Objects/gathering_interact.gd"

@export var drop_table: DropTable

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

func get_drop(player: CharacterBody2D) -> void:
	# Attempt to get a random drop from the drop table
	var selected_drop: SlotData = drop_table.get_random_drop()
	if selected_drop:
		var new_slot_data: SlotData = selected_drop.duplicate() as SlotData  # Duplicate so we don't modify the original
		new_slot_data.set_quantity(rng.randi_range(1, 3))  # Set random quantity if needed
		player.inventory_data.pick_up_slot_data(new_slot_data)
		print("Collected item: ", selected_drop.item_data.name, " x", new_slot_data.quantity)
	else:
		print("No items to collect from the bush.")

func _on_timer_timeout(player: CharacterBody2D) -> void:
	get_drop(player)
	
func _on_gather_timeout() -> void:
	get_drop(PlayerManager.player)
	activity_timer.start()
