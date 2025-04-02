extends PanelContainer

const SAVE_LIST_SCENE = preload("res://Utilities/Saving/SaveListMenu.tscn")

@onready var save_button: Button = $MarginContainer/HBoxContainer/HBoxContainer2/SaveButton
@onready var load_button: Button = $MarginContainer/HBoxContainer/HBoxContainer/LoadButton

func _on_save_button_pressed() -> void:
	GameSaveManager.save_game()
