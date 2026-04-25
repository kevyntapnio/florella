extends Node2D

@export var tilemap: TileMapLayer

var grid_objects: Dictionary = {}
var tile_size: int

func set_tilemap(map: TileMapLayer):
	tilemap = map
	get_tile_size()
		
func register_grid_object(coords: Vector2i, object):
	if not grid_objects.has(coords):
		grid_objects[coords] = [object]
	else:
		if object not in grid_objects[coords]:
			grid_objects[coords].append(object)
		
func unregister_grid_object(coords: Vector2i, object):
	
	if not grid_objects.has(coords):
		return
	
	grid_objects[coords].erase(object)
	
	if grid_objects[coords].is_empty():
		grid_objects.erase(coords)
	
func get_grid_objects(coords: Vector2i) -> Array:
	if grid_objects.has(coords):
		return grid_objects.get(coords, [])
	else:
		return []

func is_grid_occupied(grid: Vector2i) -> bool:
	return grid in grid_objects
	
func get_tile_coords(world_position: Vector2) -> Vector2i:
	var local = tilemap.to_local(world_position)
	return tilemap.local_to_map(local)

func get_world_position(grid_coordinate: Vector2i) -> Vector2:
	var local = tilemap.map_to_local(grid_coordinate)
	return tilemap.to_global(local)
	
func get_tile_size():
	var size = tilemap.tile_set.tile_size
	tile_size = size.x

func spatial_to_grid(coords: Vector2i):
	return (coords * SpatialLookup.tile_size) / tile_size
