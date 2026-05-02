extends RefCounted
class_name PlacementValidator

var tile_query: Node

func set_tile_query(scene_tile_query: Node) -> void:
	tile_query = scene_tile_query
	
func evaluate(context: PlacementContext) -> PlacementResult:
	var result = get_placement_result(context)
	return result
	
func get_placement_result(context: PlacementContext) -> PlacementResult:
	
	var placement_behavior = DecorData.PlacementBehavior
	var current_decor_behavior = context.data.placement_behavior
	
	var result: PlacementResult = null
	
	match current_decor_behavior:
		placement_behavior.FLOOR_ITEM:
			result = handle_floor_item(context)
		
		placement_behavior.WALL_ITEM:
			result = handle_wall_item(context)
			
		placement_behavior.RUG:
			result = handle_rug_item(context)
			
	return result
	
func handle_floor_item(context: PlacementContext):
	assert(tile_query != null)
	var valid:= true
	
	if not grid_unoccupied(context):
		valid = false
		return create_result(valid, null, 0, context.data.placement_behavior)
	
	for cell in context.occupied_cells:
		var grid_cell = GridManager.spatial_to_grid(cell)
		var info = tile_query.get_tile_info(grid_cell)
		
		if info.get("terrain_type") != "floor":
			valid = false 
			break ## As soon as 1 cell overlaps with other terrain, invalid placement
	
	if not valid:
		return create_result(valid, null, 0, context.data.placement_behavior)
	
	var overlap_scores = get_overlap_scores(context)
	
	if overlap_scores.is_empty():
		valid = true
		return create_result(valid, null, 0, context.data.placement_behavior)
	
	var overlap_info = classify_overlap_objects(overlap_scores)
	
	var blockers = overlap_info["blockers"]
	var surfaces = overlap_info["surfaces"]
	
	if blockers.is_empty():
		return create_result(true, null, 0, context.data.placement_behavior)
	
	if not context.data.stackable:
		return create_result(false, null, 0, context.data.placement_behavior)
	
	if surfaces.is_empty():
		return create_result(false, null, 0, context.data.placement_behavior)
		
	var surface_info = resolve_best_surface(overlap_scores, surfaces, context)
	
	return create_result(
		true,
		surface_info["surface"],
		surface_info["offset"],
		context.data.placement_behavior
	)
	
func classify_overlap_objects(overlap_scores: Dictionary) -> Dictionary:
	
	var blockers: Array[DecorObject] = []
	var surfaces: Array[DecorObject] = []
	
	for obj in overlap_scores:
		if obj.data.placement_behavior == DecorData.PlacementBehavior.RUG:
			continue 
		
		### NOTE: Remove this check when InteractionCell registry is added to the game
		## this currently exists because wall_item occupancy may spill down to floor to make it interactable
		## we're just keeping this so placement isn't invalidated by presence of wall_item on floor space
		if obj.data.placement_behavior == DecorData.PlacementBehavior.WALL_ITEM:
			continue
			
		if obj.data.has_surface:
			surfaces.append(obj)
		
		if obj.data.blocks_placement:
			blockers.append(obj)
		
	print("surfaces", surfaces)
	print("blockers:", blockers)
	return {
		"blockers": blockers,
		"surfaces": surfaces
	}
	
func handle_wall_item(context: PlacementContext) -> PlacementResult:
	
	## the chances of grid_objects existing on wall is highly unlikely, so skipped here
	## wall items do not have a floor footprint
	## if these rules ever change, we can always do so here
	
	var valid:= true
	
	for cell in context.occupied_cells:
		var grid_cell = GridManager.spatial_to_grid(cell)
		var info = tile_query.get_tile_info(grid_cell)
		
		if info.get("terrain_type") != "wallpaper":
			valid = false
			break ## as soon as overlap with non-wallpaper is detected, invalid placement
		
		## -- now check if any wall_items are occupying the cell
		
		if SpatialLookup.is_tile_occupied(cell):
			valid = false
			break ## as soon as overlap is detected, invalid placement
	
	return create_result(valid, null, 0, context.data.placement_behavior)
	
func handle_rug_item(context: PlacementContext) -> PlacementResult:
	
	## rug items can exist alongside grid_objects, so check is skipped here
	## rug items have no "weight" in the world -> non-placement blocking, non-movement blocking
	## NOTE: fine-tune for feel whether to allow rug to be placed under existing object,
	## 		or if it should only be placed before other decor gets stacked over it
	
	var valid:= true
	
	for cell in context.occupied_cells:
		var grid_cell = GridManager.spatial_to_grid(cell)
		var info = tile_query.get_tile_info(grid_cell)
		if info.get("terrain_type") != "floor":
			valid = false
			break ## invalid placement as soon as rug gets in contact with non-floor placement
			
	return create_result(valid, null, 0, context.data.placement_behavior)
	
func create_result(valid: bool, surface_object: DecorObject, \
	surface_offset: int, placement_behavior: DecorData.PlacementBehavior) -> PlacementResult:
	
	var result = PlacementResult.new()
	
	result.valid = valid
	result.surface_object = surface_object
	result.surface_offset = surface_offset
	result.placement_behavior = placement_behavior
	
	return result

func grid_unoccupied(context: PlacementContext):
	
	var cells = context.occupied_cells
	if cells == null:
		return false 
		
	for c in cells:
		var converted_grid = GridManager.spatial_to_grid(c)
		if GridManager.is_grid_occupied(converted_grid):
			return false
			
	return true
	
func get_overlap_scores(context: PlacementContext) -> Dictionary[DecorObject, int]:
	
	var overlap_scores: Dictionary[DecorObject, int] = {}
	
	for cell in context.occupied_cells:
		var overlap_objects = SpatialLookup.get_spatial_objects(cell)
		
		for obj in overlap_objects:
			if not overlap_scores.has(obj):
				overlap_scores[obj] = 1
			else:
				overlap_scores[obj] += 1
		 
	return overlap_scores
	
func resolve_best_surface(
	overlap_scores: Dictionary, 
	surfaces: Array[DecorObject], 
	context: PlacementContext) -> Dictionary:
	
	var best_surface: DecorObject = null
	var best_height: int = 0
	var best_score: int = -1
	
	for object in overlap_scores:
		if not surfaces.has(object):
			continue
			
		var current_height = object.data.variants[object.current_variant].vertical_height
		var current_score = overlap_scores[object]
		
		if current_height > best_height:
			best_height = current_height
			best_score = current_score
			best_surface = object
			
		elif current_height == best_height:
			if current_score > best_score:
				best_score = current_score
				best_surface = object
	
	if best_surface == null:
		return {"surface": null, "offset": 0}
		
	var surface_depth_index = best_surface.anchor_cell.y - context.anchor_cell.y
	var offset = best_height + (best_height * surface_depth_index)
	
	return {"surface": best_surface, "offset": offset}
	
