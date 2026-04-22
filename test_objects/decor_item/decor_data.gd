extends ItemData
class_name DecorData

enum DecorType {
	FURNITURE,
	WALL_ITEM,
	CLUTTER_ITEM,
	CARPET
}

@export var variants: Array[DecorVariant]
@export var decor_type: DecorType
@export var has_surface:= false
@export var can_stack:= false
