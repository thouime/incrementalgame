extends PanelContainer

var attack_bonus : int

# Had the collectible been obtained and set?
var is_locked : bool = false
var slot_item : ItemData

@onready var item_label: Label = $MarginContainer/VBoxContainer/ItemLabel
@onready var item_texture: TextureRect = $MarginContainer/VBoxContainer/ItemTexture
@onready var passive_label: Label = $MarginContainer/VBoxContainer/PassiveLabel
@onready var button: Button = $MarginContainer/VBoxContainer/Button

func set_item(item : ItemData, bonus : int) ->  void:
	if not item:
		print("Item not found!")
	
	slot_item = item
	set_label(item.name)
	set_texture(item.texture)
	attack_bonus = bonus

func set_label(text: String) -> void:
	item_label.text = text

func set_texture(texture: Texture2D) -> void:
	item_texture.texture = texture
	item_texture.modulate = Color(Color.GRAY, 0.5) # Half transparent gray

func set_passive(text: String) -> void:
	passive_label.text = text

func lock_item() -> void:
	
	if item_texture == null:
		printerr("Item Texture has not been set!")
		return
		
	var slot_material : Material = item_texture.material
	
	# Set default modulate
	item_texture.modulate = Color(1, 1, 1, 1)
	
	# Disable shader that dims the item to gray/semi-transparent
	if slot_material:
		slot_material.set_shader_parameter("enabled", false)
		
	is_locked = true
	
	# Add passive bonuses
	var player : Player = PlayerManager.player
	if player == null:
		printerr("No player found!")
		return
		
	player.add_bonus_attack(attack_bonus)

func _on_button_pressed() -> void:
	
	var inventory := PlayerManager.player_inventory
	
	if inventory == null:
		printerr("No inventory found!")
		return
		
	if slot_item == null:
		printerr("Item Data has not been set!")
		return
		
	var item_count : int = inventory.check_total(slot_item)
	
	if item_count <= 0:
		print("Required item for collection does not exist!")
		return
	
	elif item_count > 0:
		inventory.reduce_slot_amount(slot_item, 1)
		lock_item()
	
	# save it to a dictionary or something
	# load it on game load
	
	print("Item has been added!")
