# Handles the sending of items via automation

extends Node
class_name ItemSender

func send_item(item: ItemData) -> void:
	print("Item sent: ", item)
