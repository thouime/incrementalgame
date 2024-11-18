extends PanelContainer

const Slot = preload("res://Crafting/crafting_slot.tscn")

# Small interface element that displays info about each craftable
const CRAFT_INFO = preload("res://Crafting/craft_info.tscn")

# Reference to the tilemap
@onready var world: Node2D = $"../../World"
@onready var grass_tiles: TileMapLayer = world.get_node("Grass")

# For adding nodes to the scene
@onready var main: Node = $"../.."
@onready var crafting_grid: GridContainer = $MarginContainer/CraftingGrid
# For moving menus outside the PanelContainer
@onready var canvas_layer: CanvasLayer = $CanvasLayer

# For displaying where to build crafted objects
@onready var grid: Control = $"../../Grid"

# All the different craftable items/objects
@export var craft_datas: Array[CraftData]

# Get a reference to the player's inventory for crafting
@onready var inventory: InventoryData = PlayerManager.player_inventory

# Flag to check if mouse is hovering over Craftables for more info
var craft_hovering: bool = false

# Check if the grid is active
var grid_active: bool = false
var placement_mode: bool = false

# Temporary "ghost" object that follos the mouse.
var preview_object: Node = null
var items_to_remove: Dictionary

func _ready() -> void:
	populate_crafting_grid()

func _process(_delta: float) -> void:
	# Get the cursor's global position
	if grid_active:
		draw_grid()

func _input(event: InputEvent) -> void:
	# Handle left mouse button press
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if grid_active and placement_mode:
				if preview_object:
					# Check if object can be placed
					# Checks if attempting to place on void or another object
					if(!can_place(grid.get_cursor(), grass_tiles, 32)):
						return
					var player_state = PlayerManager.player.State
					if player_state != player_state.BUILDING:
						print("test")
						
					# Remove the required items to craft the object
					inventory.remove_items(items_to_remove)
					items_to_remove.clear()

					# Add the object to the world
					main.add_child(preview_object)
					preview_object.connect("interact", PlayerManager.player._on_interact_signal)

					# Set object position to the grid cursor position
					preview_object.position = grid.get_cursor()

					print("Object added to world.")

					# Reset the preview object for the next action
					preview_object = null

					# Change mouse mode back to visible
					Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
					grid.build_cursor.visible = false

					# Deactivate grid and placement mode
					grid_active = false
					grid.visible = false
					placement_mode = false
				else:
					print("There is no reference to the object!")
				
		# Handle cancel action (e.g., pressing the "cancel" action key)
		elif event.is_action_pressed("cancel"):
			if grid_active:
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
				grid.build_cursor.visible = false
				grid_active = false
				grid.visible = false
				placement_mode = false

func draw_grid() -> void:
	grid.draw_grid()
	grid.update_cursor()
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	grid.build_cursor.visible = true
	grid_active = true
	grid.visible = true
	placement_mode = true

# Create the crafting grid for each craftable item
func populate_crafting_grid() -> void:
	for craft_data in craft_datas:
		var slot: PanelContainer = Slot.instantiate()
		crafting_grid.add_child(slot)
		if craft_data:
			slot.set_craft_data(craft_data)
			add_info(craft_data)
		slot.craft_slot_clicked.connect(self.on_slot_clicked)
		slot.craft_slot_hovered.connect(self.on_slot_hovered)
		slot.craft_slot_exited.connect(self.on_slot_exited)

func add_info(craft_data: CraftData) -> void:
	# Create info interface that shows each type of material required
	var craft_info: PanelContainer = CRAFT_INFO.instantiate()
	canvas_layer.add_child(craft_info)
	craft_info.set_info(craft_data)
	
	var materials: Array = craft_data.material_slot_datas
	for craft_material: MaterialSlotData in materials:
		if craft_material:
			craft_info.add_material(
				craft_material.item_data, 
				craft_material.quantity
			)
			
	# Position craft_info window above crafting interface
	set_info_pos(craft_info)

func set_info_pos(craft_info: Control) -> void:
	var menu_position: Vector2 = self.global_position
	var padding: int = 10
	var new_pos: float = craft_info.get_combined_minimum_size().y + padding
	craft_info.global_position = menu_position - Vector2(0, new_pos)

func show_craft_info(craft_slot: int) -> void:
	if not craft_hovering:
		craft_hovering = true
		var craft_info: PanelContainer = canvas_layer.get_child(craft_slot)
		if craft_info:
			craft_info.show()
	
func hide_craft_info(craft_slot: int) -> void:
	if craft_hovering:
		craft_hovering = false
		var craft_info: PanelContainer = canvas_layer.get_child(craft_slot)
		if craft_info:
			craft_info.hide()
			
func on_slot_clicked(craft_slot: int, _button: int) -> void:
	try_craft(craft_datas[craft_slot])

# Check if you have required materials in inventory
# Maybe later it will automatically check external inventories like chests?
func try_craft(craft_slot: CraftData) -> void:
	var material_slots: Dictionary = {}
	var missing_materials: bool = false
	
	# Check for materials and quantities
	for craft_material in craft_slot.material_slot_datas:
		if craft_material:
			var inventory_slots: Dictionary = inventory.check_materials(
				craft_material.item_data, 
				craft_material.quantity
			)
			material_slots.merge(inventory_slots)
			if material_slots[craft_material.item_data]["missing"] > 0:
				missing_materials = true
	
	if not missing_materials:
		# Print Missing materials
		# Grid view 
		craft(material_slots, craft_slot)
	else:
		# Craft the materials
		print_missing(material_slots)
		
func craft(material_slots: Dictionary, craft_slot: CraftData) -> void:
	if craft_slot.type == craft_slot.Type.OBJECT:
		print("Preparing grid...")
		var new_object: StaticBody2D = craft_slot.object_scene.instantiate()
		var sprite: Sprite2D = new_object.get_node("Sprite1")
		
		# Ensure unique material and shader
		if new_object.material:
			var new_material: ShaderMaterial = new_object.material.duplicate()
			if new_material.shader:
				new_material.shader = new_material.shader.duplicate()
			new_object.material = new_material
		
		preview_object = new_object
		items_to_remove = material_slots
		# Change the cursor to the sprite of the craft
		grid.set_cursor(sprite)
		draw_grid()

	elif craft_slot.type == craft_slot.Type.ITEM:
		var new_item: SlotData = craft_slot.slot_data.duplicate()
		# Try to add item to inventory, otherwise set it to null
		if inventory.pick_up_slot_data(new_item):
			inventory.remove_items(material_slots)
			print("Item added to inventory.")
		else:
			new_item = null
	else:
		print("Craftable isn't assigned a type!")

# Show a list of all the missing materials and the quantity needed
func print_missing(missing_materials: Dictionary) -> void:
	var missing_string: String = (
		"Not enough materials to finish craft!\n" +
		"Missing Materials:\n"
	)

	for missing_material: ItemData in missing_materials.keys():
		var quantity: int = missing_materials[material]["missing"]
		if quantity > 0:
			missing_string += (
				"     - " + 
				missing_material.name + ": x" + 
				str(quantity) + "\n"
			)
	
	print(missing_string)

func check_area(cursor_position: Vector2, grid_size: int) -> bool:
	# Define the area to check for overlapping objects
	var shape: RectangleShape2D = RectangleShape2D.new()
	shape.extents = Vector2(float(grid_size) / 2.0, float(grid_size) / 2.0)

	# Set up the physics query
	var space_state: PhysicsDirectSpaceState2D = (
		get_world_2d().direct_space_state
	)
	var query: PhysicsShapeQueryParameters2D = (
		PhysicsShapeQueryParameters2D.new()
	)
	query.shape = shape
	query.transform = Transform2D(0, cursor_position)
	
	# Perform the physics query
	var results: Array = space_state.intersect_shape(query, 1)
	if results.size() > 0:
		print("There is an object in the way.")
	return results.size() == 0

func check_ground(
		cursor_position: Vector2, 
		tile_map_layer: TileMapLayer, 
		grid_size: int
	) -> bool:
	# Convert the world position to the local position relative to the tilemap
	var local_position: Vector2 = tile_map_layer.to_local(cursor_position)
	
	if grid_size > 16:
		# Calculate the top-left corner of the bounding box for the 32x32 object
		var top_left_cell: Vector2 = tile_map_layer.local_to_map(
			local_position - Vector2(
				float(grid_size) / 2.0, 
				float(grid_size) / 2.0
			)
		)
		# Calculate the number of cells to check in each direction (2 cells horizontally and vertically for a 32x32 object)
		var cells_to_check: Vector2 = Vector2(2, 2)
		
		# Loop through the affected cells and check if there's a tile at each position
		for x in range(top_left_cell.x, top_left_cell.x + cells_to_check.x):
			for y in range(top_left_cell.y, top_left_cell.y + cells_to_check.y):
				# Check if there's a tile at this position
				var data: TileData = tile_map_layer.get_cell_tile_data(Vector2i(x, y))
				
				if !data:  # If no tile data exists at this position
					print("There's no land to place on.")
					return false  # Return false immediately if no tile is found
				
				var tile_id: int = data.terrain
				
				# Check for specific tiles (e.g., ground or grass)
				if tile_id == 0:
					print("Ground tile found at ", x, y)
				elif tile_id == 1:
					print("Grass tile found at ", x, y)
				else:
					print("Other tile found at ", x, y)
					
		# If all cells are valid, return true after all checks
		return true
	else:
		# For smaller grid sizes (e.g., <= 16), just check a single tile
		var clicked_cell: Vector2 = tile_map_layer.local_to_map(local_position)
		var data: TileData = tile_map_layer.get_cell_tile_data(clicked_cell)
		if data:
			var tile_id: int = data.terrain
			print(tile_id)
			return true
		else:
			print("There's no land to place on.")
			return false

func can_place(
	cursor_position: Vector2, 
	tilemap: TileMapLayer, 
	grid_size: int
) -> bool:
	return (check_area(cursor_position, grid_size) and 
			check_ground(cursor_position, tilemap, grid_size))
	
func on_slot_hovered(index: int) -> void:
	show_craft_info(index)

func on_slot_exited(index: int) -> void:
	hide_craft_info(index)
