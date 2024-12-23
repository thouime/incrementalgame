extends PanelContainer

@onready var v_box_container: VBoxContainer = $MarginContainer/VBoxContainer
@onready var slot_name: Label = $MarginContainer/VBoxContainer/SlotName
@onready var rich_text_label: RichTextLabel = $MarginContainer/VBoxContainer/RichTextLabel

# Display information about the slot
func set_info(resource: Resource) -> void:
	slot_name.text = resource.name
	rich_text_label.text = resource.description
