extends Node
class_name TileQuery

@export var tilemap: TileMapLayer
var initialized:= false

const FLOOR_TILE = [
	Vector2i(0, 0),
	Vector2i(4, 0),
	Vector2i(1, 2),
	Vector2i(2, 2),
	Vector2i(3, 2),
	Vector2i(2, 3)
	]
	
const BOTTOM_WALLPAPER = Vector2i(0, 4)
const TOP_WALLPAPER = Vector2i(4, 4)

const INVALID_TILE = Vector2i(-1, -1)

const DEFAULT_TILE_INFO = {
	"terrain_type": null,
	"properties": {
		"buildable" = false,
		"walkable" = false,
		"spawnable" = false
	}
}

var tile_cache: Dictionary = {}

	
func initialize(map):
	tilemap = map
	initialized = true
	
	build_cache()
	enrich_cache()
	
func build_cache():
	var cells = tilemap.get_used_cells()
	
	for cell in cells:
		tile_cache[cell] = DEFAULT_TILE_INFO.duplicate()
		
	for cell in cells:
		var coords = tilemap.get_cell_atlas_coords(cell)
		
		var tile = tile_cache[cell]
		
		if coords in FLOOR_TILE:
			tile["terrain_type"] = "floor"
		elif coords == BOTTOM_WALLPAPER or coords == TOP_WALLPAPER:
			tile["terrain_type"] = "wallpaper"
		else:
			tile["terrain_type"] = "wall_boundary"
			
func enrich_cache():
	
	for t in tile_cache:
		var tile = tile_cache[t]
		
		tile["properties"] = get_terrain_properties(tile["terrain_type"])
		
func get_terrain_properties(terrain_type):
	
	if terrain_type == "floor":
		return {
			"buildable": true,
			"walkable": true,
			"spawnable": true
		}
	
	if terrain_type == "wallpaper":
		return {
			"buildable": true,
			"walkable": false,
			"spawnable": false
		}
		
	if terrain_type == "wall_boundary":
		return {
			"buildable": false,
			"walkable": false,
			"spawnable": false
		}
	
func get_tile_info(tile):
	return tile_cache.get(tile, DEFAULT_TILE_INFO.duplicate())
