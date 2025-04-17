extends Control

signal dungeon_start

@onready var name_label: Label = $HBoxContainer/MarginContainer/VBoxContainer/NameLabel
@onready var difficulty_label: Label = $HBoxContainer/MarginContainer/VBoxContainer/DifficultyLabel
@onready var enemy_count_label: Label = $HBoxContainer/MarginContainer/VBoxContainer/EnemyCountLabel
@onready var completions_label: Label = $HBoxContainer/MarginContainer/VBoxContainer/CompletionsLabel
@onready var completion_time_label: Label = $HBoxContainer/MarginContainer/VBoxContainer/CompletionTimeLabel
@onready var loot_table_container: HBoxContainer = $HBoxContainer/MarginContainer/VBoxContainer/LootTableContainer
@onready var loot_table_label: Label = $HBoxContainer/MarginContainer/VBoxContainer/LootTableContainer/LootTableLabel
@onready var start: Button = $HBoxContainer/MarginContainer/VBoxContainer/VBoxContainer/Start

func set_labels(dungeon_data: DungeonResource) -> void:
	name_label.text = dungeon_data.name
	difficulty_label.text = "Difficulty: " + str(dungeon_data.difficulty)
	enemy_count_label.text = "Enemies: " + str(dungeon_data.enemy_count)
	completions_label.text = "Completions: " + str(dungeon_data.completions)
	completion_time_label.text = "Estimated Time: " + str(dungeon_data.estimated_completion)

func _on_back_pressed() -> void:
	dungeon_start.emit()
