extends Resource

class_name TileInfo

@export var name: String = ""
@export_multiline var description: String = ""
@export var icon_texture: AtlasTexture
@export var tile_id : int # ID of the tile in the TileSet
# Tilemap coordinate of the atlas file for the position of the tile
@export var tile_map_coordinates : Vector2 = Vector2(2, 1)
@export var tile_texture : AtlasTexture
@export var item : ItemData
