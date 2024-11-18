extends "res://Objects/gathering_interact.gd"

@export var drop_table: DropTable

var rng: RandomNumberGenerator = RandomNumberGenerator.new()

func _ready() -> void:
	super._ready()
	# Initialize all the drops added from the editor
	drop_table.setup()

# Override
func interact_action(player: CharacterBody2D) -> void:
	super(player)
	# Specific bush logic
	print("Gathering from bush...")

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
