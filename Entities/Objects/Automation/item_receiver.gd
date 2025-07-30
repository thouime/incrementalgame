# Handles the receiving of items via automation

extends Node
class_name ItemReceiver

func receive_item(item: ItemData) -> void:
	print("Received item: ", item)
