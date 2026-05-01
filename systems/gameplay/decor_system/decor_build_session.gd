extends Node2D
class_name BuildSession

var decor_factory: DecorFactory
var placement_validator: PlacementValidator
var ysort: Node

var current_decor: DecorObject = null
var current_hovered_cell: Vector2i
var current_hovered_position: Vector2
var current_preview_result: PlacementResult

func setup() -> void:
	
	decor_factory = DecorFactory.new()
	placement_validator = PlacementValidator.new()
	
	var tile_query = get_tree().get_first_node_in_group("tile_query")
	placement_validator.set_tile_query(tile_query)
	
	ysort = get_tree().get_first_node_in_group("ysort_world")
	
func initialize_build_session(decor_data: DecorData) -> void:
	assert(ysort != null)
	
	if current_decor != null:
		current_decor.queue_free()
	
	current_hovered_position = get_current_hovered_position()
	var decor = decor_factory.create_decor(decor_data)
	ysort.add_child(decor)
	
	decor.global_position = get_current_hovered_position()
	
	current_decor = decor
	
func _process(delta: float) -> void:
	if current_decor == null:
		return
	
	var preview_position = get_current_hovered_position()
	var new_hovered_cell = SpatialLookup.get_cell_coords(get_global_mouse_position())
	
	## Only re-evaluate placement when current_hovered_cell has changed
	if new_hovered_cell != current_hovered_cell:
		
		current_hovered_cell = new_hovered_cell
		var occupancy_anchor_cell = get_anchor_cell()
		
		var context = PlacementContext.new()
		context.anchor_cell = occupancy_anchor_cell
		context.occupied_cells = current_decor.get_occupied_cells(occupancy_anchor_cell)
		context.data = current_decor.data
		
		var result = placement_validator.evaluate_placement(context)
		
		if result == null:
			push_error("BuildSession ERROR: placement_result not returned by placement_validator")
			return
		
		var surface_object = result.surface_object
		var offset = result.surface_offset
				
		if result.surface_object != null:
			current_decor.apply_stacked_offset(true, offset)
			preview_position.y = surface_object.global_position.y + 1.0
			print(offset)
		else:
			current_decor.apply_stacked_offset(false, offset)
			
		current_preview_result = result
	
	set_preview_modulate(current_preview_result.valid)
	if current_preview_result.surface_object != null:
		preview_position.y = current_preview_result.surface_object.position.y + 1.0
		
	current_decor.global_position = preview_position

func set_preview_modulate(valid: bool) -> void:
	if current_decor == null:
		return
	if valid:
		current_decor.modulate = Color(1.0, 1.0, 1.0, 0.5)
	else:
		current_decor.modulate = Color(1.0, 0, 0, 0.5)
func get_anchor_cell() -> Vector2i:
	return current_hovered_cell + Vector2i(-1, -1)
	
	## This function returns anchor_cell where cell occupancy is calculated from
	## See docs on Coordinate Systems
		
func get_current_hovered_position() -> Vector2i:
	
	### Normalize global mouse_pos first to provide grid snapping for preview positioning
	
	var hovered_cell = SpatialLookup.get_cell_coords(get_global_mouse_position())
	return SpatialLookup.get_world_position(hovered_cell)

func handle_place_request() -> bool:
	if current_decor == null:
		return false
		
	var request = PlacementRequest.new()
	request.current_decor = current_decor
	request.current_variant = current_decor.current_variant
	request.anchor_cell = get_anchor_cell()
	request.origin_cell = current_hovered_cell
	
	if not DecorSystem.request_placement(request):
		print("placement failed")
		return false
		
	current_decor = null
	return true
		
func switch_variant() -> bool:
	
	if current_decor == null:
		return false
		
	var variants = current_decor.data.variants
	
	if variants.is_empty():
		return false
		
	var new_variant = current_decor.current_variant + 1
	
	new_variant = new_variant % variants.size()
	
	current_decor.current_variant = new_variant
	current_decor.apply_variant_texture(new_variant)
	
	return true

func cancel_build_mode() -> void:
	if current_decor:
		current_decor.queue_free()
	current_decor = null
	
func refresh_build_mode(item_data: DecorData) -> void:
	cancel_build_mode()
	
	if item_data is DecorData:
		initialize_build_session(item_data)
		
