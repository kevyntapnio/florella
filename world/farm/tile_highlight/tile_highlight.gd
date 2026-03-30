extends Node2D

@export var tilemap: TileMapLayer

func highlight_tile(grid_coordinate: Vector2i, valid):
	
	var tile_position = tilemap.map_to_local(grid_coordinate)
	position = tile_position
	
	if valid:
		modulate = Color(1, 1, 1, 1)
	else:
		remove_highlight()
	
func remove_highlight():
	hide()
	
func show_highlight():
	show()
