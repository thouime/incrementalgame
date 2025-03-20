extends Control

@onready var global_slider: HSlider = $VBoxContainer/GlobalVolume/HBoxContainer/GlobalSlider
@onready var global_spin_box: SpinBox = $VBoxContainer/GlobalVolume/HBoxContainer/GlobalSpinBox
@onready var music_slider: HSlider = $VBoxContainer/MusicVolume/HBoxContainer/MusicSlider
@onready var music_spin_box: SpinBox = $VBoxContainer/MusicVolume/HBoxContainer/MusicSpinBox
@onready var sfx_slider: HSlider = $VBoxContainer/SFXlVolume/HBoxContainer/SFXSlider
@onready var sfx_spin_box: SpinBox = $VBoxContainer/SFXlVolume/HBoxContainer/SFXSpinBox
@onready var back: Button = $VBoxContainer/Back

func _ready():
	# load settings
	global_spin_box.value = global_slider.value
	music_spin_box.value = music_slider.value
	sfx_spin_box.value = sfx_slider.value
	AudioManager.set_global_volume(global_slider.value)
	AudioManager.set_music_volume(music_slider.value)
	AudioManager.set_sfx_volume(sfx_slider.value)

func _on_back_pressed() -> void:
	# save settings
	get_tree().change_scene_to_file("res://Stages/MainMenu/MainMenu.tscn")

func _on_global_slider_value_changed(value: float) -> void:
		
	global_spin_box.value = global_slider.value
	AudioManager.set_global_volume(global_slider.value)

func _on_music_slider_value_changed(value: float) -> void:
	
	music_spin_box.value = music_slider.value
	AudioManager.set_music_volume(music_slider.value)


func _on_sfx_slider_value_changed(value: float) -> void:
	
	sfx_spin_box.value = sfx_slider.value
	AudioManager.set_sfx_volume(sfx_slider.value)
