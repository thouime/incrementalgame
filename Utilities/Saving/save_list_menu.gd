extends Control

const SAVE_SLOT = preload("res://Utilities/Saving/save_slot.tscn")

var game_saves : Array

@onready var save_slot_container: VBoxContainer = $HBoxContainer/ScrollContainer/MarginContainer/VBoxContainer/MarginContainer/HBoxContainer/SaveSlotContainer
@onready var back: Button = $HBoxContainer/VBoxContainer2/MarginContainer/HBoxContainer/Back

func _ready() -> void:
	game_saves = GameSaveManager.get_saves()
	for slot in game_saves:
		
		# Create the button
		var save_slot = SAVE_SLOT.instantiate()
		# Get the labels from the button
		var slot_label: Label = save_slot.get_node(
			"HBoxContainer/VBoxContainer/MarginContainer/HBoxContainer/Slot"
		)
		var name_label: Label = save_slot.get_node(
			"HBoxContainer/VBoxContainer/MarginContainer/HBoxContainer/SaveName"
		)
		var played_label: Label = save_slot.get_node(
			"HBoxContainer/VBoxContainer/MarginContainer2/TimePlayed"
		)
		
		# Get save file json with info about the save
		var save_info = GameSaveManager.get_save_info(slot)
		var slot_id : int = save_info.get("slot")
		save_slot.slot_id = slot_id
		
		slot_label.text = "Slot: " + str(slot_id)
		name_label.text = save_info.get("save_name")
		played_label.text = "Time Played: " + str(save_info.get("duration"))

		save_slot_container.add_child(save_slot)
	
func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://Stages/MainMenu/MainMenu.tscn")
