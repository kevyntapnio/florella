extends Node2D

@export var tilemap: TileMapLayer

func highlight_tile(grid_coordinate: Vector2i):
	
	var tile_position = tilemap.map_to_local(grid_coordinate)
	position = tile_position
	
func remove_highlight():
	hide()
