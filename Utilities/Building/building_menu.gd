extends Control

@onready var generic_menu: PanelContainer = $GenericMenu

func _ready() -> void:
	var state_machine: Node = PlayerManager.state_machine
	generic_menu.slot_clicked.connect(state_machine._handle_building_tile)
