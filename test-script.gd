func find_terrain_subtype(cell):
	var terrain_layer
	
	for layer in terrain_layers:
		var tile = layer.get_cell_atlas_coords(cell)
		var type = layer.get_meta("terrain_type")
		
		if tile != Vector2i(-1, -1):
			if is_tile_meaningful(type, tile):
				terrain_layer = layer
				break
				
	var subtype = DEFAULT_INFO["subtype"]
	var cell_below = cell + Vector2i(0, 1)
	var cell_above = cell + Vector2i(0, -1)
	
	var cell_type = find_terrain_type(cell)
	
	var cell_below_type = DEFAULT_INFO["terrain_type"]
	var cell_above_type = DEFAULT_INFO["terrain_type"]
	
	if terrain_layer.get_cell_atlas_coords(cell_below) == Vector2i(-1, -1):
		pass
	
	cell_below_type = find_terrain_type(cell_below)
	
	if terrain_layer.get_cell_atlas_coords(cell_above):
		pass
		
	cell_above_type = find_terrain_type(cell_above)
	
	if cell_type == "ground":
		var tile_atlas = terrain_layer.get_cell_atlas_coords(cell)
		if tile_atlas == FULL_TILE:
			subtype = "dirt"
		elif tile_atlas == EMPTY_TILE:
			subtype = "grass"
		elif tile_atlas == EMPTY_TILE and cell_above_type == "cliff":
			subtype = "cliff_face"
			
	if cell_type == "cliff":
		if cell_below_type == "cliff":
			subtype = "cliff_top"
		else:
			subtype = "cliff_face"
	
	return subtype
	
