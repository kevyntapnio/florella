extends Node
class_name WorldTileLookup

var terrain_layers = []
const EMPTY_TILE = Vector2i(0, 3)
const FULL_TILE = Vector2i(2, 1)

var cliff_top_tiles = [
	Vector2i(0, 0),
	Vector2i(1, 0),
	Vector2i(2, 0),
	Vector2i(3, 0),
	Vector2i(1, 1),
	Vector2i(2, 1),
	Vector2i(3, 2),
	Vector2i(1, 3)
	]

func set_terrain_layers():
	## Level Node calls this function
	terrain_layers = get_tree().get_nodes_in_group("terrain")
	
	terrain_layers.sort_custom(func(a, b):
		return a.get_meta("terrain_priority", 0) > b.get_meta("terrain_priority", 0)
		)
		
func get_tile_info(cell):
	var terrain_layer = null
	var tile_atlas
	
	if terrain_layers.is_empty():
		print("WorldTileQuery ERROR: No TileMapLayers set")
		return _get_default_cell_info()
		
	for terrain in terrain_layers:
		if not terrain.has_meta("terrain_priority") or not terrain.has_meta("terrain_type"):
			print("WorldTileQuery ERROR: Incomplete or no meta_data set for TileMapLayers:", terrain)
			return _get_default_cell_info()
			
	for terrain in terrain_layers: 
		
		tile_atlas = terrain.get_cell_atlas_coords(cell)
		var type = terrain.get_meta("terrain_type")
		
		if tile_atlas == Vector2i(-1, -1):
			continue
			
		if not is_tile_meaningful(type, tile_atlas):
			continue
		else:
			terrain_layer = terrain
			break
	
	if terrain_layer == null:
		print("WorldTileQuery ERROR: No valid terrain layer found")
		return _get_default_cell_info()
		
	var terrain_properties = {
		"grass": {
			"spawnable": true,
			"walkable": true,
			"buildable": true
		},
		"dirt": {
			"spawnable": false,
			"walkable": true,
			"buildable": false
		},
		"cliff_top": {
			"spawnable": true,
			"walkable": true,
			"buildable": true
		},
		"cliff_face": {
			"spawnable": false,
			"walkable": false,
			"buildable": false
		}
	}
		
	var tile = terrain_layer.get_cell_atlas_coords(cell)
	var subtype = null
	var terrain_type = terrain_layer.get_meta("terrain_type")
	
	if terrain_type == "ground":
		if tile == FULL_TILE:
			subtype = "dirt"
		else:
			subtype = "grass"
	
	elif terrain_type == "cliff":
		if tile in cliff_top_tiles:
			subtype = "cliff_top"
		else:
			subtype = "cliff_face"
	
	var cell_info = {
		"terrain_type" : terrain_type,
		"subtype": subtype,
		"properties": terrain_properties[subtype]
	}
	
	return cell_info
	
func _get_default_cell_info():
	return {
		"terrain_type": "invalid",
		"subtype": "invalid",
		"properties": {
			"spawnable": false,
			"walkable": false,
			"buildable": false
		}
	}

func is_tile_meaningful(type, atlas):
	
	if atlas == Vector2i(-1, -1):
		return false
		
	if type == "cliff" and atlas == EMPTY_TILE:
		return false
	
	if type == "water" and atlas == EMPTY_TILE:
		return false
		
	return true
