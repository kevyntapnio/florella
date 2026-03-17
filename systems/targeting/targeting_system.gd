extends Node2D

@export var tilemap: TileMapLayer

var current_target_coords
var facing_direction
var player_tile_coords
var player_global_position

func update_current_target():
	
	var hovered_tile = tilemap.local_to_map(get_global_mouse_position())
	var direction_tile = player_tile_coords + facing_direction
	
	current_target_coords = hovered_tile

func _process(delta):
	print(player_global_position)
