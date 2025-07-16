extends "res://Entities/Objects/gathering_interact.gd"

@onready var activity_timer: ActivityTimer = $ActivityTimer

func _ready() -> void:
	super._ready()
	set_object_name("tree")
	
	activity_timer.timer_finished.connect(_on_gather_timeout)
	activity_timer.set_time(gather_time)
	activity_timer.show()

	
func interact_action(_player: CharacterBody2D) -> void:

	if equipment_requirement:
		var required_equip : ItemData = equipment_requirement.item_data
		var required_type : int = required_equip.equipment_type
		var required_name : String = (
			required_equip.EquipType.find_key(required_type)
		)
		var equipment : Dictionary = PlayerManager.player_equipment.get_equips()
		if not equipment.has(required_name):
			print("Can't chop with hands! Need: ", required_equip.name)
			return

	# Randomize leaves and sticks to be added to inventory
	if current_interacts < interact_limit:
		activity_timer.start()
		print("Interact Limit: ", interact_limit)
		print("Gathering from: ", get_object_name())
	elif activity_timer.regen_complete:
		print("regen complete true")
		current_interacts = 0
		activity_timer.start()
		print("Gathering from: ,", get_object_name())

func stop_interact_action(_player: CharacterBody2D) -> void:
	activity_timer.stop()

func _on_gather_timeout() -> void:
	super._on_gather_timeout()
	# Start the regeneration of the resource, set as regen duration in export
	if current_interacts >= interact_limit:
		print("Resource has been depleted! It needs to regenerate...")
		activity_timer.start_regen(regen_duration, self)
		return
	# Automatically restart timer
	activity_timer.start()
