extends Node2D

var spatial_objects: Dictionary = {}
@export var tile_size: int = 16
var initialized:= false
	
func register_spatial_object(coords: Vector2i, object):
	
	if not spatial_objects.has(coords):
		spatial_objects[coords] = [object]
	else:
		if object not in spatial_objects[coords]:
			spatial_objects[coords].append(object)
		
func unregister_spatial_object(coords, object):
	
	if not spatial_objects.has(coords):
		return
	
	spatial_objects[coords].erase(object)
	
	if spatial_objects[coords].is_empty():
		spatial_objects.erase(coords)
		
func get_objects_at_world_pos(pos: Vector2) -> Array:
	var cell = get_cell_coords(pos)
	return get_spatial_objects(cell)
	
func get_spatial_objects(coords: Vector2i) -> Array:

	if spatial_objects.has(coords):
		return spatial_objects.get(coords, [])
	else:
		return []

func is_tile_occupied(tile: Vector2i) -> bool:
	return tile in spatial_objects
	
func get_cell_coords(world_position: Vector2) -> Vector2i:
	return Vector2i((world_position / tile_size).floor())

func get_world_position(cell: Vector2i) -> Vector2:
	return Vector2(
		cell.x * tile_size,
		cell.y * tile_size
		)
	
