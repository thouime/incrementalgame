extends ItemData

class_name ItemDataEquip

enum EquipType {
	ITEM,
	ARMOR,
	AXES,
	PICKAXES
}

@export var equipment_type: EquipType = EquipType.ITEM
@export var defense: int
