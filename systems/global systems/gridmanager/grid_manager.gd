extends Node2D

@export var tilemap: TileMapLayer

var grid_objects = {}

func set_tilemap(map: TileMapLayer):
	tilemap = map
		
func register_grid_object(coords: Vector2i, object):
	grid_objects[coords] = object
	
func unregister_grid_object(coords: Vector2i):
	grid_objects.erase(coords)
	
func get_grid_object(coords: Vector2i):
	return grid_objects.get(coords)

func get_tile_coords(world_position: Vector2) -> Vector2i:
	var local = tilemap.to_local(world_position)
	return tilemap.local_to_map(local)
