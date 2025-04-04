extends HBoxContainer

@onready var slot: Label = $SaveSlot/HBoxContainer/VBoxContainer/MarginContainer/HBoxContainer/Slot
@onready var save_name: Label = $SaveSlot/HBoxContainer/VBoxContainer/MarginContainer/HBoxContainer/SaveName
@onready var time_played: Label = $SaveSlot/HBoxContainer/VBoxContainer/MarginContainer2/TimePlayed
@onready var save_slot: Button = $SaveSlot
@onready var rename_button: Button = $VBoxContainer/RenameButton
@onready var delete_button: Button = $VBoxContainer/DeleteButton
@onready var rename_dialog: AcceptDialog = $RenameDialog
@onready var input_field: LineEdit = $RenameDialog/InputField
@onready var confirmation_dialog: ConfirmationDialog = $ConfirmationDialog

# Store the save slot id for loading
var slot_id : int
var save_location : String

func _ready() -> void:
	save_slot.pressed.connect(_on_button_pressed)
	rename_button.pressed.connect(_on_rename_button_pressed)
	delete_button.pressed.connect(_on_delete_button_pressed)

func _on_button_pressed() -> void:
	GameSaveManager.set_current_save(save_location)
	GameSaveManager.game_loaded = true
	AudioManager.play_music("world", 3)
	get_tree().change_scene_to_file("res://main.tscn")
	
func _on_rename_button_pressed() -> void:
	rename_dialog.get_ok_button().pressed.connect(_on_text_entered)
	input_field.text = ""
	input_field.text_submitted.connect(_on_text_entered)
	# Set exclusive to false so the user can close the game while dialog is open
	rename_dialog.set_exclusive(false)
	rename_dialog.popup_centered()
	input_field.grab_focus()
	rename_dialog.show()

func _on_text_entered(_text := "") -> void:
	var user_input := input_field.text
	rename_dialog.get_ok_button().pressed.disconnect(_on_text_entered)
	input_field.text_submitted.disconnect(_on_text_entered)
	save_name.text = user_input
	rename_dialog.hide()
	# Get save file json with info about the save
	GameSaveManager.update_save_info(save_location, "save_name", user_input)

func _on_delete_button_pressed() -> void:
	confirmation_dialog.set_exclusive(false)
	confirmation_dialog.connect("confirmed", _on_confirmed)
	confirmation_dialog.connect("canceled", _on_canceled)
	confirmation_dialog.show()

func _on_confirmed() -> void:
	confirmation_dialog.disconnect("confirmed", _on_confirmed)
	confirmation_dialog.hide()
	GameSaveManager.delete_save(save_location)
	queue_free()

func _on_canceled() -> void:
	confirmation_dialog.disconnect("confirmed", _on_confirmed)
	confirmation_dialog.disconnect("canceled", _on_canceled)
	
