extends Node2D

@export var tilemap: TileMapLayer

var grid_objects = {}

func _ready():
	print(grid_objects)
		
func register_grid_object(coords: Vector2i, object):
	grid_objects[coords] = object
	
func unregister_grid_object(coords: Vector2i):
	grid_objects.erase(coords)
	
func get_grid_object(coords: Vector2i):
	return grid_objects.get(coords)
