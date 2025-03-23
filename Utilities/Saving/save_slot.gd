extends Button

@onready var slot: Label = $HBoxContainer/VBoxContainer/MarginContainer/HBoxContainer/Slot
@onready var save_name: Label = $HBoxContainer/VBoxContainer/MarginContainer/HBoxContainer/SaveName
@onready var time_played: Label = $HBoxContainer/VBoxContainer/MarginContainer2/TimePlayed

# Store the save slot id for loading
var slot_id : int

func _ready():
	self.pressed.connect(_on_button_pressed)

func _on_button_pressed():
	GameSaveManager.set_save_slot(slot_id)
	AudioManager.play_music("world", 3)
	get_tree().change_scene_to_file("res://main.tscn")
