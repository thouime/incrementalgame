extends Node

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

func save_settings() -> void:
	
	var file = FileAccess.open(settings_path, FileAccess.WRITE)
	
	if file:
		file.store_string(JSON.stringify(user_settings))
		file.close()
		print("Settings saved successfully.")
	else:
		print("Failed to open settings file for writing.")

func load_settings() -> void:
	
	var file := FileAccess.open(settings_path, FileAccess.READ)
	
	if not file:
		print("Save file not found!")
		return
	
	var json := JSON.new()
	var error := json.parse(file.get_line())
	if error != OK:
		print("Failed to parse JSON: ", json.get_error_message())
		return
	
	var parsed_settings := json.get_data() as Dictionary
	
	if parsed_settings is Dictionary:
		user_settings = parsed_settings
		print("Settings loaded successfully.")
		apply_settings()
	else:
			print("Failed to parse settings.")

func apply_settings():
	AudioManager.set_global_volume(user_settings["global_volume"])
	AudioManager.set_music_volume(user_settings["music_volume"])
	AudioManager.set_sfx_volume(user_settings["sfx_volume"])
