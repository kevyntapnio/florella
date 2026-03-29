extends Node2D

@export var tilemap: TileMapLayer

var grid_objects: Dictionary = {}

func set_tilemap(map: TileMapLayer):
	tilemap = map
		
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
		print("GRID MANAGER ERROR: Coords not registered")

func get_tile_coords(world_position: Vector2) -> Vector2i:
	var local = tilemap.to_local(world_position)
	return tilemap.local_to_map(local)
