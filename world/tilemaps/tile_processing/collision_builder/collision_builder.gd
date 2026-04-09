extends Node

@export var tile_query: Node2D
@export var cliff_layer: TileMapLayer
@export var cliff_top_colliders: TileMapLayer
@export var cliff_ground_colliders: TileMapLayer

## This mapping may be temporary until I finalize my collision tileset ##
## Will make a separate tile registry script to keep collision_builder script from declaring all these constants when more tiles are added
const CLIFF_GROUND_RULES = {
	"cliff_top": FULL_TILE,
	"upper_edge_top": BOTTOM_ONLY,
	"upper_cliff_face": FULL_TILE,
	"lower_cliff_face": TOP_ONLY
	}

const FULL_TILE = {
	"source": 0,
	"atlas": Vector2i(0, 3),
	"alt": 0
}

const BOTTOM_ONLY = {
	"source": 0,
	"atlas": Vector2i(0, 3),
	"alt": 1
}

const TOP_ONLY = {
	"source": 0,
	"atlas": Vector2i(0, 3),
	"alt": 2
}

func _ready():
	var debug_cell = Vector2i(13, 12)
	
	await get_tree().process_frame
	
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
		
		var type = tile_query.get_tile_info(coords)["terrain_type"]
		neighbor_tiles[neighbor] = type 
		
	return neighbor_tiles
	
func set_colliders():
	
	clear_layers()
	
	var tile_cache = tile_query.tile_cache
	
	if tile_cache.is_empty():
		print("CollisionBuilder ERROR: tile_cache is empty")
		return
		
	for tile in tile_cache:
		var data = tile_cache[tile]
		
		if not data.has("terrain_type"):
			continue
			
		var terrain_type = tile_cache[tile]["terrain_type"]
		
		set_cliff_ground_collider(tile, terrain_type)
		#set_cliff_top_collider(tile, terrain_type)
			
func set_cliff_ground_collider(tile, terrain_type):
	
	var tile_type = ""
	
	var collision_rules = {
		"upper_edge": BOTTOM_ONLY,
		"bottom_edge": FULL_TILE,
		"full_terrain": FULL_TILE,
		"lower_bottom_edge": TOP_ONLY
	}
	
	var neighbor_tiles = check_neighbor_tiles(tile)
	
	if terrain_type == "cliff":
		
		if neighbor_tiles["tile_below"] == "cliff":
			tile_type = "full_terrain"
		else:
			tile_type = "bottom_edge"
		
		if neighbor_tiles["tile_above"] != "cliff":
			tile_type = "upper_edge"
			
	## handles lower_cliff_face spillover into ground layer ##
	if terrain_type == "ground":
		if neighbor_tiles["tile_above"] != "ground":
			tile_type = "lower_bottom_edge"
			
	if not tile_type in collision_rules:
		return
		
	var collider = collision_rules.get(tile_type)
	
	cliff_ground_colliders.set_cell(tile, collider["source"], collider["atlas"], collider["alt"])

func set_cliff_top_collider(tile, terrain_type):
	
	### TEMPORARY MAPPING: Values represent "Alternative" in tile atlas###
	### Right now, kept as reference for mapping, not used in actual execution 
	### Will edit code later to match tile_registry
	var cliff_top_rules = {
		"upper_left_corner": 5,
		"upper_right_corner": 6,
		"lower_left_corner": 7,
		"lower_right_corner": 8,
		"upper_edge": 2,
		"bottom_edge": 1,
		"right_edge": 4,
		"left_edge": 3
	}
	
	## Added this here temporarily, but my idea is to have set_collider send target_type when calling builder function
	## This function works for all terrain_types that don't need to handle spillover
	var target_type = "cliff"
	
	var layer = cliff_top_colliders
	var neighbor_tiles = check_neighbor_tiles(tile)
	var tile_shape
	
	if terrain_type == target_type:
		### Set corners first ###
		if neighbor_tiles["tile_above"] != terrain_type:
			if neighbor_tiles["tile_to_left"] != terrain_type:
				layer.set_cell(tile, 0, Vector2i(0, 3), 5)
			if neighbor_tiles["tile_to_right"] != terrain_type:
				layer.set_cell(tile, 0, Vector2i(0, 3), 6)
		
		if neighbor_tiles["tile_below"] != terrain_type:
			if neighbor_tiles["tile_to_left"] != terrain_type:
				layer.set_cell(tile, 0, Vector2i(0, 3), 7)
			if neighbor_tiles["tile_to_right"] != terrain_type:
				layer.set_cell(tile, 0, Vector2i(0, 3), 8)
		 
		### Handle regular edges and don't modify corner tiles ###
		var atlas = layer.get_cell_atlas_coords(tile)
		
		if atlas == Vector2i(-1, -1):
			if neighbor_tiles["tile_to_left"] != terrain_type:
				layer.set_cell(tile, 0, Vector2i(0, 3), 3)
			if neighbor_tiles["tile_to_right"] != terrain_type:
				layer.set_cell(tile, 0, Vector2i(0, 3), 4)
			if neighbor_tiles["tile_above"] != terrain_type:
				layer.set_cell(tile, 0, Vector2i(0, 3), 2)
			if neighbor_tiles["tile_below"] != terrain_type:
				layer.set_cell(tile, 0, Vector2i(0, 3), 1)
	
func apply_collider_tile(layer, tile, tile_shape):
	layer.set_cell(tile, 0, Vector2i(0, 3), tile_shape)
		
func clear_layers():
	cliff_ground_colliders.clear()
	cliff_top_colliders.clear()
