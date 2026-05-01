extends RefCounted
class_name PlacementValidator

var tile_query: Node

func set_tile_query(scene_tile_query):
	tile_query = scene_tile_query
	
func evaluate_placement(context: PlacementContext) -> PlacementResult:
	var result = PlacementResult.new()
	
	var valid = is_placement_valid(context)
	var surface_info = get_surface_info(context)
	
	result.valid = valid
	result.on_surface = has_overlap(context)
	result.surface_object = surface_info.get("surface")
	result.surface_offset = surface_info.get("offset", 0)
	
	return result
	
func is_placement_valid(context: PlacementContext) -> bool:
	
	if not terrain_is_buildable(context):
		return false
		
	if not context.data.stackable:
		if not grid_unoccupied(context): ### As of current implementation, all grid_objects block buildability
			return false
			
	if has_overlap(context):
		if not surface_is_buildable(context):
			return false
				
	return true
		
func grid_unoccupied(context: PlacementContext):
	
	var cells = context.occupied_cells
	if cells == null:
		return false 
		
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
			
		if data.requires_wall and terrain_type != "wallpaper":
			return false
			
		if not info["properties"]["buildable"]:
			return false
			
	return true
	
func surface_is_buildable(context: PlacementContext) -> bool:
	if context.occupied_cells == null:
		return false
		
	var occupied_cells = context.occupied_cells
	var data = context.data
	
	var has_valid_surface = false
	
	for cell in occupied_cells:
		var objects = SpatialLookup.get_spatial_objects(cell)
		
		for obj in objects:
			if obj.data.has_surface:
				has_valid_surface = true
				break
				
	if not has_valid_surface:
		return false
		
	return true
	
func has_overlap(context: PlacementContext) -> bool:
	
	var occupied_cells = context.occupied_cells
	
	for cell in occupied_cells:
		if SpatialLookup.is_tile_occupied(cell):
			return true
			
	return false
			
func get_surface_info(context: PlacementContext) -> Dictionary:
	
	## Register every surface_object detected as a key in surface_scores
	## Assign 'int' as value to keep count of how many cells report an overlap with object
	## example: {"decor_object": 1} and then for every match found, surface_scores[surface] += 1
	
	var surface_scores: Dictionary[DecorObject, int] = {}
	
	for cell in context.occupied_cells:
		var found_surfaces = SurfaceRegistry.get_surface_objects(cell)
		
		for surface in found_surfaces:
			if not surface_scores.has(surface) and is_instance_valid(surface):
				surface_scores[surface] = 1
			else:
				surface_scores[surface] += 1
	
	var best_surface: DecorObject = null
	var best_height: int = 0
	var best_score: int = -1
	
	for surface in surface_scores:
		var current_height = surface.data.variants[surface.current_variant].vertical_height
		var current_score = surface_scores[surface]
		
		if current_height > best_height:
			best_height = current_height
			best_score = current_score
			best_surface = surface
			
		elif current_height == best_height:
			if current_score > best_score:
				best_score = current_score
				best_surface = surface
	
	if best_surface == null:
		return {"surface": null, "offset": 0}
		
	var surface_depth_index  = best_surface.anchor_cell.y - context.anchor_cell.y
	
	var offset = best_height + (best_height * surface_depth_index)
	
	return {"surface": best_surface, "offset": offset}
	
