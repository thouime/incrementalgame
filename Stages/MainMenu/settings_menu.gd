extends Control

@onready var global_slider: HSlider = $HBoxContainer/MarginContainer/VBoxContainer/GlobalVolume/HBoxContainer/GlobalSlider
@onready var global_spin_box: SpinBox = $HBoxContainer/MarginContainer/VBoxContainer/GlobalVolume/HBoxContainer/GlobalSpinBox
@onready var music_slider: HSlider = $HBoxContainer/MarginContainer/VBoxContainer/MusicVolume/HBoxContainer/MusicSlider
@onready var music_spin_box: SpinBox = $HBoxContainer/MarginContainer/VBoxContainer/MusicVolume/HBoxContainer/MusicSpinBox
@onready var sfx_slider: HSlider = $HBoxContainer/MarginContainer/VBoxContainer/SFXlVolume/HBoxContainer/SFXSlider
@onready var sfx_spin_box: SpinBox = $HBoxContainer/MarginContainer/VBoxContainer/SFXlVolume/HBoxContainer/SFXSpinBox
@onready var back: Button = $HBoxContainer/MarginContainer/VBoxContainer/VBoxContainer/Back
@onready var res_label: Label = $HBoxContainer/MarginContainer/VBoxContainer/ResolutionOptions/ResLabel
@onready var res_button: OptionButton = $HBoxContainer/MarginContainer/VBoxContainer/ResolutionOptions/ResButton


# This standard resolution does not work with the default 480, 720
#{"label" : "640x480", "size" : Vector2i(640, 480)},

var resolutions := [
	{"label" : "480x720", "size" : Vector2i(480, 720)},
	{"label" : "1280x720", "size" : Vector2i(1280, 720)},
	{"label" : "1920x1080", "size" : Vector2i(1920, 1080)},
	{"label" : "2560x1440", "size" : Vector2i(2560, 1440)},
	{"label" : "3840x2160", "size" : Vector2i(3840, 2160)}
]

func _ready() -> void:
	
	# Only enable back button if accessed from the main menu
	if GameSaveManager.game_loaded:
		back.hide()
	
	add_resolutions()
	load_settings()

func load_settings() -> void:
	global_slider.value = int(SettingsManager.user_settings["global_volume"])
	music_slider.value = int(SettingsManager.user_settings["music_volume"])
	sfx_slider.value = int(SettingsManager.user_settings["sfx_volume"])
	
	global_spin_box.value = int(global_slider.value)
	music_spin_box.value = int(music_slider.value)
	sfx_spin_box.value = int(sfx_slider.value)

	AudioManager.set_global_volume(int(global_slider.value))
	AudioManager.set_music_volume(int(music_slider.value))
	AudioManager.set_sfx_volume(int(sfx_slider.value))

	res_button.select(get_resolution_index(SettingsManager.user_settings["resolution"]))

func save_settings() -> void:
	SettingsManager.user_settings["global_volume"] = int(global_slider.value)
	SettingsManager.user_settings["music_volume"] = int(music_slider.value)
	SettingsManager.user_settings["sfx_volume"] = int(sfx_slider.value)
	SettingsManager.user_settings["resolution"] = (
		resolutions[res_button.get_selected_id()].size
	)
	SettingsManager.save_settings()

func _on_global_slider_value_changed(value: float) -> void:
	global_spin_box.value = int(value)
	AudioManager.set_global_volume(int(value))

func _on_global_spin_box_value_changed(value: float) -> void:
	global_slider.value = int(value)
	AudioManager.set_global_volume(int(value))

func _on_music_slider_value_changed(value: float) -> void:
	music_spin_box.value = int(value)
	AudioManager.set_music_volume(int(value))

func _on_music_spin_box_value_changed(value: float) -> void:
	music_slider.value = int(value)
	AudioManager.set_music_volume(int(value))

func _on_sfx_slider_value_changed(value: float) -> void:
	sfx_spin_box.value = int(value)
	AudioManager.set_sfx_volume(int(value))

func _on_sfx_spin_box_value_changed(value: float) -> void:
	sfx_slider.value = int(value)
	AudioManager.set_sfx_volume(int(value))

func add_resolutions() -> void:
	for i in range(resolutions.size()):
		res_button.add_item(resolutions[i].label, i)
	
	res_button.item_selected.connect(_on_resolution_selected)

func _on_resolution_selected(index: int) -> void:
	var new_resolution : Vector2 = resolutions[index].size
	DisplayServer.window_set_size(new_resolution)
	get_window().move_to_center()

func get_resolution_index(res_size: Vector2i) -> int:
	return resolutions.find(
		resolutions.filter(func(
			res: Dictionary) -> bool: return res["size"] == res_size
		).front()
	)

func _on_back_pressed() -> void:
	save_settings()
	get_tree().change_scene_to_file("res://Stages/MainMenu/MainMenu.tscn")
