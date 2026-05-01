extends ItemData
class_name DecorData

enum DecorType {
	FURNITURE,
	WALL_ITEM,
	CLUTTER_ITEM,
	CARPET
}

enum DecorRuntimeBehavior {
	STATIC,
	GENERIC_INTERACTIVE,
	LIGHT_SOURCE,
	MUSIC_PLAYER
}

enum PlacementBehavior {
	RUG, 
	FLOOR_ITEM,
	WALL_ITEM,
}

@export var variants: Array[DecorVariant]
@export var decor_type: DecorType
@export var decor_runtime_behavior: DecorRuntimeBehavior
@export var placement_behavior: PlacementBehavior
@export var has_surface:= false
@export var stackable:= false
@export var blocks_movement:= true
@export var blocks_placement:= true
@export var requires_wall:= false
