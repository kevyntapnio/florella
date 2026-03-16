extends Node2D

@export var tilemap: TileMapLayer

var tiles = {}

func _ready():
	var farm_tiles = get_tree().get_nodes_in_group("farm_tiles")
	
	## This can be compacted into 1 var, but can be written like this for readability
	for tile in farm_tiles:
		var tile_global = tile.global_position
		var tile_local = tilemap.to_local(tile_global)
		var tile_coords = tilemap.local_to_map(tile_local)
		
		tiles[tile_coords] = tile

func get_tile_at(grid_coordinate):
	if tiles.has(grid_coordinate):
		return tiles[grid_coordinate]
	else:
		return null
		
