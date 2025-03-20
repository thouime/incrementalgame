extends Control

@onready var new_game: Button = $"VBoxContainer/New Game"
@onready var load_game: Button = $"VBoxContainer/Load Game"
@onready var settings: Button = $VBoxContainer/Settings
@onready var exit: Button = $VBoxContainer/Exit

# Path to settings file
var settings_path = "user://settings.json"

# Default Settings
var user_settings = {
	"global_volume" : 25,
	"music_volume" : 25,
	"sfx_volume" : 25,
	"resolution" : Vector2(480, 720),
	"fullscreen" : false
}

func _ready() -> void:
	load_settings()
	apply_settings()
	if not AudioManager.current_music:
		AudioManager.play_music("menu")

func save_settings():
	
	var file = FileAccess.open(settings_path, FileAccess.WRITE)
	
	if file:
		file.store_string(JSON.stringify(user_settings))
		file.close()
		print("Settings saved successfully.")
	else:
		print("Failed to open settings file for writing.")

func load_settings():
	
	var file = FileAccess.open(settings_path, FileAccess.READ)
	
	if file:
		var json_data = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var loaded_settings = json.parse(json_data)
		
		if loaded_settings is Dictionary:
			user_settings = loaded_settings
			print("Settings loaded successfully.")
			apply_settings()
		else:
			print("Failed to parse settings.")
	else:
		print("Settings file does not exist.")

func apply_settings():
	AudioManager.set_global_volume(user_settings["global_volume"])
	AudioManager.set_music_volume(user_settings["music_volume"])
	AudioManager.set_sfx_volume(user_settings["sfx_volume"])

func _on_new_game_pressed() -> void:
	AudioManager.play_music("world", 3)
	get_tree().change_scene_to_file("res://main.tscn")

func _on_load_game_pressed() -> void:
	pass # Replace with function body.

func _on_settings_pressed() -> void:
	get_tree().change_scene_to_file("res://Stages/MainMenu/SettingsMenu.tscn")

func _on_exit_pressed() -> void:
	get_tree().quit()
