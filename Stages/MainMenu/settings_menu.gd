extends Control

@onready var global_slider: HSlider = $HBoxContainer/MarginContainer/VBoxContainer/GlobalVolume/HBoxContainer/GlobalSlider
@onready var global_spin_box: SpinBox = $HBoxContainer/MarginContainer/VBoxContainer/GlobalVolume/HBoxContainer/GlobalSpinBox
@onready var music_slider: HSlider = $HBoxContainer/MarginContainer/VBoxContainer/MusicVolume/HBoxContainer/MusicSlider
@onready var music_spin_box: SpinBox = $HBoxContainer/MarginContainer/VBoxContainer/MusicVolume/HBoxContainer/MusicSpinBox
@onready var sfx_slider: HSlider = $HBoxContainer/MarginContainer/VBoxContainer/SFXlVolume/HBoxContainer/SFXSlider
@onready var sfx_spin_box: SpinBox = $HBoxContainer/MarginContainer/VBoxContainer/SFXlVolume/HBoxContainer/SFXSpinBox
@onready var back: Button = $HBoxContainer/MarginContainer/VBoxContainer/VBoxContainer/Back

func _ready():
	load_settings()

func load_settings():
	global_slider.value = SettingsManager.user_settings["global_volume"]
	music_slider.value = SettingsManager.user_settings["music_volume"]
	sfx_slider.value = SettingsManager.user_settings["sfx_volume"]
	global_spin_box.value = global_slider.value
	music_spin_box.value = music_slider.value
	sfx_spin_box.value = sfx_slider.value
	AudioManager.set_global_volume(global_slider.value)
	AudioManager.set_music_volume(music_slider.value)
	AudioManager.set_sfx_volume(sfx_slider.value)

func save_settings():
	SettingsManager.user_settings["global_volume"] = global_slider.value
	SettingsManager.user_settings["music_volume"] = music_slider.value
	SettingsManager.user_settings["sfx_volume"] = sfx_slider.value
	SettingsManager.save_settings()

func _on_global_slider_value_changed(value: float) -> void:
		
	global_spin_box.value = global_slider.value
	AudioManager.set_global_volume(global_slider.value)

func _on_global_spin_box_value_changed(value: float) -> void:

	global_slider.value = global_spin_box.value
	AudioManager.set_global_volume(global_slider.value)

func _on_music_slider_value_changed(value: float) -> void:
	
	music_spin_box.value = music_slider.value
	AudioManager.set_music_volume(music_slider.value)

func _on_music_spin_box_value_changed(value: float) -> void:
	
	music_slider.value = music_spin_box.value
	AudioManager.set_music_volume(music_slider.value)

func _on_sfx_slider_value_changed(value: float) -> void:
	
	sfx_spin_box.value = sfx_slider.value
	AudioManager.set_sfx_volume(sfx_slider.value)

func _on_sfx_spin_box_value_changed(value: float) -> void:
	
	sfx_slider.value = sfx_spin_box.value
	AudioManager.set_sfx_volume(sfx_slider.value)

func _on_back_pressed() -> void:
	save_settings()
	get_tree().change_scene_to_file("res://Stages/MainMenu/MainMenu.tscn")
