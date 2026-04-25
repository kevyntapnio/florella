extends Node2D

var tilemap: TileMapLayer

var current_target_coords
var current_target_cell
var facing_direction
var player_tile_coords
var player_global_position
var initialized := false

func set_tilemap(map: TileMapLayer):
	tilemap = map
	initialized = true

func update_current_target():
	if not initialized:
		return
		
	var hovered_tile = tilemap.local_to_map(get_global_mouse_position())
	var spatial_cell = SpatialLookup.get_cell_coords(get_global_mouse_position())
	var direction_tile = player_tile_coords + facing_direction
	
	current_target_coords = hovered_tile
	current_target_cell = spatial_cell

	
	
