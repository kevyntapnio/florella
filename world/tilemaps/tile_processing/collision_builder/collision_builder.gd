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

func _ready() -> void:
	pass
	
func set_colliders():
	
	clear_layers()
	
	var tile_cache = tile_query.tile_cache
	
	if tile_cache.is_empty():
		print("CollisionBuilder ERROR: tile_cache is empty")
		return
		
	for tile in tile_cache:
		var data = tile_cache[tile]
		
		if not data.has("subtype"):
			return
			
		var subtype = tile_cache[tile]["subtype"]
		set_cliff_ground_collider(tile, subtype)
		set_cliff_top_collider(tile, subtype)
			
func set_cliff_ground_collider(tile, subtype):
	
	## if subtype needs no colliders ##
	if subtype not in CLIFF_GROUND_RULES:
		return
		
	var collider = CLIFF_GROUND_RULES[subtype]
	
	cliff_ground_colliders.set_cell(tile, collider["source"], collider["atlas"], collider["alt"])
	
func set_cliff_top_collider(tile, subtype):
	
	var tile_cache = tile_query.tile_cache
	
	if subtype == "cliff_top":
		
		var tile_to_left = tile + Vector2i(-1, 0)
		var tile_to_right = tile + Vector2i(1, 0)
		var tile_above = tile + Vector2i(0, -1)
		var tile_below = tile + Vector2i(0, 1)
			
		if tile_cache[tile_to_left]["terrain_type"] == "ground":
			print("set left edge on tile")
		elif tile_cache[tile_to_right]["terrain_type"] == "ground":
			print("set right edge on tile")
		elif tile_cache[tile_above]["terrain_type"] == "ground":
			print("set upper edge on tile")
		elif tile_cache[tile_above]["terrain_type"] == "ground":
			print("set lower edge on tile")
		else:
			print("do nothing")
			
func clear_layers():
	cliff_ground_colliders.clear()
	cliff_top_colliders.clear()
