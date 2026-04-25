extends Node

@export var tile_query: Node

func set_tile_query(scene_tile_query):
	tile_query = scene_tile_query

func can_place(context: PlacementContext) -> bool:
	
	if not tiles_unoccupied(context):
		return false
		
	if not surface_is_buildable(context):
		return false
		
	if not terrain_is_buildable(context):
		return false
		
	return true
		
func tiles_unoccupied(context: PlacementContext):
	
	var cells = context.occupied_cells
	
	for c in cells:
		var converted_grid = GridManager.spatial_to_grid(c)
		if GridManager.is_grid_occupied(converted_grid):
			return false
			
	return true
	
func terrain_is_buildable(context: PlacementContext) -> bool:
	
	var data = context.data
	
	if tile_query == null:
		push_error("PlacementValidator ERROR: failed to load tile_query")
		return false
		
	var cells = context.occupied_cells
	
	for c in cells:
		var converted_grid = GridManager.spatial_to_grid(c)
		
		var info = tile_query.get_tile_info(converted_grid)
		var terrain_type = info["terrain_type"]
		
		if not data.requires_wall and terrain_type == "wallpaper":
			return false
			
		if not info["properties"]["buildable"]:
			return false
			
	return true
	
func surface_is_buildable(context: PlacementContext) -> bool:
	if context.occupied_cells == null:
		return false
		
	var occupied_cells = context.occupied_cells
	var data = context.data
	
	for cell in occupied_cells:
		var objects = SpatialLookup.get_spatial_objects(cell)
		
		for obj in objects:
			if not obj.data.has_surface:
				return false
		
	return true
	
func get_adjusted_pos(context: PlacementContext) -> Vector2:
	var occupied_cells = context.occupied_cells
	
	var offset = Vector2(0, 0)
	
	for cell in occupied_cells:
		var objects = SpatialLookup.get_spatial_objects(cell)
		
		for obj in objects:
			offset = obj.data.variants[obj.current_variant].vertical_height
			return offset
			
	return offset

func check_overlap(context: PlacementContext):
	
	var occupied_cells = context.occupied_cells
	
	for cell in occupied_cells:
		if not SpatialLookup.is_tile_occupied(cell):
			return false
	
	return true
		
		
