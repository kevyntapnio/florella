extends Node
class_name WorldTileLookup

var terrain_layers = []
var tile_cache = {}

const FULL_TILE = Vector2i(2, 1)
const EMPTY_TILE = Vector2i(0, 3)

const DEFAULT_INFO = {
	"terrain_type": "invalid",
	"subtype": "invalid",
	"properties": {
		"spawnable": false,
		"walkable": false,
		"buildable": false
	}
}

func set_terrain_layers():
	## Level Node calls this function
	terrain_layers = get_tree().get_nodes_in_group("terrain")
	
	if not is_terrain_valid():
		return
		
	sort_layer_priority()
	build_cache()
	
func sort_layer_priority():
	terrain_layers.sort_custom(func(a, b):
		return a.get_meta("terrain_priority", 0) > b.get_meta("terrain_priority", 0)
		)
		
func get_tile_info(cell):
	return tile_cache.get(cell, DEFAULT_INFO)
	
func build_cache():
	tile_cache.clear()
	
	var all_cells = collect_used_cells()
	
	for cell in all_cells:
		var info = base_cache_info(cell)
		tile_cache[cell] = info
	
	for cell in all_cells:
		enrich_cache(cell)
		
func base_cache_info(cell):
	var terrain_layer = find_winning_layer(cell)
	
	var terrain_type = find_terrain_type(terrain_layer, cell)
	
	var info = {
		"source_layer": terrain_layer,
		"terrain_type": terrain_type,
		"subtype": null
	}
	
	return info
	
func collect_used_cells():
	var all_cells = {}
	
	for layer in terrain_layers:
		for cell in layer.get_used_cells():
			all_cells[cell] = true
			
	return all_cells
	
func is_terrain_valid():
	
	for layer in terrain_layers:
		if not layer.has_meta("terrain_type") or not layer.has_meta("terrain_priority"):
			print("WorldTileQuery ERROR: Missing or incomplete meta_data for:", layer)
			return false
	
	return true
		
func find_winning_layer(cell):
	
	var terrain_layer = null
	
	if terrain_layers.is_empty():
		print("WorldTileQuery ERROR: terrain_layers is empty! Call set_terrain_layers on ready")
		return terrain_layer
		
	for layer in terrain_layers:
			var type = layer.get_meta("terrain_type")
			var tile = layer.get_cell_atlas_coords(cell)
		
			if tile != Vector2i(-1, -1):
				if is_tile_meaningful(type, tile):
					terrain_layer = layer
					break
					
	return terrain_layer

func find_terrain_type(terrain_layer, cell):
	
	var terrain_type = DEFAULT_INFO["terrain_type"]
	
	if terrain_layer == null:
		return terrain_type
	
	terrain_type = terrain_layer.get_meta("terrain_type")
	
	return terrain_type
	
func enrich_cache(cell):
	var subtype = DEFAULT_INFO["subtype"]
		
	var cell_type = tile_cache[cell]["terrain_type"]
	
	var cell_below = cell + Vector2i(0, 1)
	var cell_above = cell + Vector2i(0, -1)
	
	var cell_below_type = DEFAULT_INFO["terrain_type"]
	var cell_above_type = DEFAULT_INFO["terrain_type"]
	
	if cell_below in tile_cache:
		cell_below_type = tile_cache[cell_below]["terrain_type"]
		
	if cell_above in tile_cache:
		cell_above_type = tile_cache[cell_above]["terrain_type"]
	
	if cell_type == "ground":
		var terrain_layer = tile_cache[cell]["source_layer"]
		
		if terrain_layer == null:
			tile_cache["subtype"] = subtype
			tile_cache["properties"] = get_terrain_property(subtype)
			return
			
		var tile_atlas = terrain_layer.get_cell_atlas_coords(cell)
		
		if tile_atlas == Vector2i(-1, -1):
			tile_cache["subtype"] = subtype
			tile_cache["properties"] = get_terrain_property(subtype)
			return
		
		if tile_atlas == EMPTY_TILE:
			if cell_above_type == "cliff":
				subtype = "lower_cliff_face"
			else:
				subtype = "grass"
		else:
			subtype = "dirt"
	
	elif cell_type == "cliff":
		if cell_below_type == "ground":
			subtype = "upper_cliff_face"
		elif cell_above_type == "ground":
			subtype = "upper_edge_top"
		else:
			subtype = "cliff_top"
	
	var terrain_property = get_terrain_property(subtype)
	
	tile_cache[cell]["subtype"] = subtype
	tile_cache[cell]["properties"] = terrain_property
	
func get_terrain_property(subtype):
	
	var properties = {
		"spawnable": false,
		"walkable": false,
		"buildable": false
	}
	
	if subtype == "invalid":
		return properties
	
	if subtype == "grass":
		properties = {
			"spawnable": true,
			"walkable": true,
			"buildable": true
		}
	if subtype == "dirt":
		properties = {
		"spawnable": false,
		"walkable": true,
		"buildable": true
		}
	if subtype == "cliff_top":
		properties = {
		"spawnable": true,
		"walkable": true,
		"buildable": false
		}
	if subtype == "upper_edge_top":
		properties = {
		"spawnable": true,
		"walkable": true,
		"buildable": true
		}
	if subtype == "upper_cliff_face":
		return properties
	if subtype == "lower_cliff_face":
		return properties
	
	return properties
	
func is_tile_meaningful(type, tile):
	if tile == EMPTY_TILE:
		if type == "ground":
			return true
		if type == "cliff":
			return false
	return true
	
