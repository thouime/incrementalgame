extends Resource

# A Craftable Item or Object
class_name CraftData

# Handle if this is a simple item or object to be crafted
enum Type { ITEM, OBJECT }
@export var type: Type

# New object or item to be created
@export var object_scene: PackedScene
@export var slot_data: SlotData

@export var name: String = ""
@export_multiline var description: String = ""
@export var menu_texture: AtlasTexture
@export var material_slot_datas: Array[MaterialSlotData]
