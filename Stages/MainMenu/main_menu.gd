extends Control

@onready var new_game: Button = $"VBoxContainer/New Game"
@onready var load_game: Button = $"VBoxContainer/Load Game"
@onready var settings: Button = $VBoxContainer/Settings
@onready var exit: Button = $VBoxContainer/Exit

func _ready() -> void:
	SettingsManager.load_settings()
	SettingsManager.apply_settings()
	if not AudioManager.current_music:
		AudioManager.play_music("menu")

func _on_new_game_pressed() -> void:
	AudioManager.play_music("world", 3)
	get_tree().change_scene_to_file("res://main.tscn")

func _on_load_game_pressed() -> void:
	get_tree().change_scene_to_file("res://Utilities/Saving/SaveListMenu.tscn")

func _on_settings_pressed() -> void:
	get_tree().change_scene_to_file("res://Stages/MainMenu/SettingsMenu.tscn")

func _on_exit_pressed() -> void:
	get_tree().quit()
