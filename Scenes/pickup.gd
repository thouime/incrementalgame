extends Area2D

@export var slot_data: SlotData

@onready var sprite_2d: Sprite2D = $Sprite2D

func _ready() -> void:
	sprite_2d.texture = slot_data.item_data.texture
	
func _physics_process(delta: float) -> void:
	sprite_2d.rotate(delta)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.inventory_data.pick_up_slot_data(slot_data):
		queue_free()
