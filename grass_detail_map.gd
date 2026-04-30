extends TileMapLayer

@export var tile_query: Node2D
@export var seed: int = 0

const variants = [
	Vector2i(0, 3),
	Vector2i(0, 4),
	Vector2i(1, 4),
	Vector2i(2, 4),
	Vector2i(3, 4)
]

var rng = RandomNumberGenerator.new()

func add_grass_tile_variants():
	rng.seed = seed
	
	var tile_list = tile_query.tile_cache
	
	for tile in tile_list:
		var neighbor = check_neighbor_tiles(tile)
		
		if neighbor.get("tile_above") != "grass":
			continue
		if neighbor.get("tile_below") != "grass":
			continue
		if neighbor.get("tile_to_right") != "grass":
			continue
		if neighbor.get("tile_to_left") != "grass":
			continue
			
		var type = tile_list[tile]["subtype"]
		
		var random_tile = variants.pick_random()
		if type == "grass":
			set_cell(tile, 0, random_tile, 0)
			
func check_neighbor_tiles(tile):
	
	var neighbor_coords = {
		"tile_above" = tile + Vector2i(0, -1),
		"tile_below" = tile + Vector2i(0, 1),
		"tile_to_left" = tile + Vector2i(-1, 0),
		"tile_to_right" = tile + Vector2i(1, 0)
	}
	
	var neighbor_tiles = {}
	
	for neighbor in neighbor_coords:
		var coords = neighbor_coords[neighbor]
		
		var type = tile_query.get_tile_info(coords)["subtype"]
		neighbor_tiles[neighbor] = type 
		
	return neighbor_tiles
