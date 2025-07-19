extends Control

const SAVE_SLOT = preload("res://Utilities/Saving/save_slot.tscn")

@onready var save_slot_container: VBoxContainer = $HBoxContainer/ScrollContainer/MarginContainer/VBoxContainer/MarginContainer/HBoxContainer/SaveSlotContainer
@onready var back: Button = $HBoxContainer/VBoxContainer2/MarginContainer/HBoxContainer/Back

func _ready() -> void:
	
	# Only enable back button if accessed from the main menu
	if GameSaveManager.game_loaded:
		back.hide()
	
	var game_saves : Dictionary = GameSaveManager.get_saves_data()
	
	var current_slot := 1
	
	# If the dictionary is empty, there aren't any saves
	if not game_saves:
		return
		
	for slot : String in game_saves["save_files"]:
		# Create the button
		var save_slot : HBoxContainer = SAVE_SLOT.instantiate()
		# Get the labels from the button
		var slot_label: Label = save_slot.get_node(
			"SaveSlot/HBoxContainer/VBoxContainer/MarginContainer/HBoxContainer/Slot"
		)
		var name_label: Label = save_slot.get_node(
			"SaveSlot/HBoxContainer/VBoxContainer/MarginContainer/HBoxContainer/SaveName"
		)
		var played_label: Label = save_slot.get_node(
			"SaveSlot/HBoxContainer/VBoxContainer/MarginContainer2/TimePlayed"
		)
		
		# Get save file json with info about the save
		var save_info : Dictionary = GameSaveManager.get_save_info(slot)
		
		if save_info == null:
			printerr("Save has been corrupted!")
			return
		
		print(save_info)
		
		save_slot.slot_id = current_slot
		save_slot.save_location = slot

		slot_label.text = "Slot: " + str(current_slot)
		name_label.text = save_info.get("save_name")
		
		played_label.text = "Time Played: " + (
			format_playtime(save_info.get("duration"))
		)

		save_slot_container.add_child(save_slot)
		current_slot += 1

func format_playtime(duration : float) -> String:
	var seconds := int(duration) % 60
	var minutes := int(duration / 60 ) % 60
	var hours := int(duration / 3600)
	return "%02d:%02d:%02d" % [hours, minutes, seconds]
	
func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://Stages/MainMenu/MainMenu.tscn")
