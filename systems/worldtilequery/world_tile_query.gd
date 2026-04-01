extends Node
class_name WorldTileLookup

var terrain_layers = []

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
		
		if tile_atlas != Vector2i(-1, -1):
			terrain_layer = terrain
			break
	
	if terrain_layer == null:
		print("WorldTileQuery ERROR: No TileMapLayer found")
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
		if tile == Vector2i(2, 1):
			subtype = "dirt"
		else:
			subtype = "grass"
	
	elif terrain_type == "cliff":
		if tile == Vector2i(2, 1):
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
