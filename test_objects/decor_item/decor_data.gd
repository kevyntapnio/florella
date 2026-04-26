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
@export var stackable:= false
@export var blocks_movement:= true
@export var blocks_placement:= true
@export var requires_wall:= false
@export var light_source:= false
