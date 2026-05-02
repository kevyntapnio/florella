extends Node

var build_session: BuildSession
var decor_factory: DecorFactory
var placement_validator: PlacementValidator
var ysort

var placed_decor: Dictionary = {}

func setup(y_sort_ref, tile_query) -> void:
	decor_factory = DecorFactory.new()
	placement_validator = PlacementValidator.new()
	placement_validator.set_tile_query(tile_query)
	
	ysort = y_sort_ref
	
func request_placement(request: PlacementRequest) -> bool:
	
	var context = PlacementContext.new()
	context.anchor_cell = request.anchor_cell
	context.data = request.current_decor.data
	context.occupied_cells = request.current_decor.get_occupied_cells(request.anchor_cell)
	
	var result = placement_validator.evaluate(context)
	
	if not result.valid:
		return false
	
	var decor_instance = request.current_decor
	
	var on_surface:= false
	
	if result.surface_object != null:
		decor_instance.surface_object = result.surface_object
		on_surface = true
		
	decor_instance.anchor_cell = request.anchor_cell
	decor_instance.origin_cell = request.origin_cell
	decor_instance.set_placed_mode(request.current_variant, on_surface, result.surface_offset)
	
	if result.placement_behavior == DecorData.PlacementBehavior.RUG:
		decor_instance.z_index = -1
		decor_instance.y_sort_enabled = false
	
	var decor_info = {
		"anchor_cell": request.anchor_cell,
		"id": request.current_decor.data.id,
		"is_stacked": on_surface,
		"variant": request.current_variant
		}
	
	var origin_cell = request.origin_cell
	
	if not placed_decor.has(origin_cell):
		placed_decor[origin_cell] = []
		
	placed_decor[origin_cell].append(decor_info)
	
	SoundManager.play("wood_placed")
	InventorySystem.remove_item(request.current_decor.data.id, 1)
	
	return true
	
func request_removal(object: DecorObject):
	
	var origin_cell = object.origin_cell
	var anchor_cell = object.anchor_cell
	
	if not placed_decor.has(origin_cell):
		return false
		
	var stack_at_tile = placed_decor[origin_cell]
	
	for i in range(stack_at_tile.size()):
		var entry = stack_at_tile[i]
		
		if entry["anchor_cell"] == anchor_cell:
			stack_at_tile.remove_at(i)
			break
		
	if stack_at_tile.is_empty():
		placed_decor.erase(origin_cell)
	
	var pos = SpatialLookup.get_world_position(origin_cell)
	var stack = ItemStack.new()
	
	stack.item_data = object.data
	stack.quantity = 1
	
	WorldItemSpawner.spawn(stack, pos)
	
	object.queue_free()
	
	SoundManager.play("ui_hover")
	
func get_save_data():
	var save_data = {}
	
	for origin_cell in placed_decor:
		var stacked_at_tile = placed_decor[origin_cell]
		var key = str(origin_cell.x) + "," + str(origin_cell.y)
		
		var saved_items_list = []
		for decor_item in stacked_at_tile:
			var decor_copy = decor_item.duplicate()
		
			var anchor_cell = decor_copy["anchor_cell"]
			var anchor_key = str(anchor_cell.x) + "," + str(anchor_cell.y)
			decor_copy["anchor_cell"] = anchor_key
		
			saved_items_list.append(decor_copy)
		
		save_data[key] = saved_items_list

	return save_data

func load_from_data(data):
	if data == null: 
		push_error("DecorSystem ERROR: failed to load data from saved file")
		return
		
	placed_decor.clear()
	
	for key in data: 
		var parts = key.split(",")
		var origin_cell = Vector2i(parts[0].to_int(), parts[1].to_int())
		
		var items_at_tile = data[key]
		
		var parsed_list = []
		
		for decor_item in items_at_tile:
		
			var id = decor_item.get("id")
			var variant = int(decor_item.get("variant", 0))
			var is_stacked = decor_item.get("is_stacked")
			
			var anchor_str = decor_item.get("anchor_cell")
			var a_parts = anchor_str.split(",")
			var anchor_cell = Vector2i(a_parts[0].to_int(), a_parts[1].to_int())
		
			var decor_info = {
					"anchor_cell": anchor_cell,
					"id": id,
					"variant": variant,
					"is_stacked": is_stacked
			}
			parsed_list.append(decor_info)
		
		placed_decor[origin_cell] = parsed_list
		
func spawn_decor():
	if not is_instance_valid(ysort):
		push_error("DecorSystem ERROR: invalid ysort")
		return
		
	var spawned_instances: Array[DecorObject] = []
	
	for origin_cell in placed_decor:
		var stack_at_tile = placed_decor[origin_cell]
		
		for decor_item in stack_at_tile:
			var data = ItemDatabase.get_item(decor_item["id"])
			var variant = decor_item["variant"]
			
			var decor_instance = decor_factory.create_decor(data)
			
			decor_instance.anchor_cell = decor_item["anchor_cell"]
			decor_instance.origin_cell = origin_cell
			decor_instance.is_stacked = decor_item["is_stacked"]
			decor_instance.current_variant = decor_item["variant"]
				
			ysort.add_child(decor_instance)
				
			decor_instance.position = SpatialLookup.get_world_position(origin_cell)
				
			## spawn everything first without offsets
			decor_instance.set_placed_mode(variant, decor_item["is_stacked"], 0)
			
			if decor_instance.data.placement_behavior == DecorData.PlacementBehavior.RUG:
				decor_instance.z_index = -1
				decor_instance.y_sort_enabled = false
				
			spawned_instances.append(decor_instance)
	
	for decor_instance in spawned_instances:
		if decor_instance.is_stacked:
			apply_stacked_offset(decor_instance)
			
func apply_stacked_offset(decor_instance: DecorObject):
		
	var context = PlacementContext.new()
	context.anchor_cell = decor_instance.anchor_cell
	context.data = decor_instance.data
	context.occupied_cells = decor_instance.get_occupied_cells(decor_instance.anchor_cell)
	context.placement_behavior = decor_instance.data.placement_behavior
	
	var result = placement_validator.evaluate(context)
		
	var surface = result.surface_object
		
	if surface != null and is_instance_valid(surface):
		decor_instance.position.y = surface.position.y + 1.0
		decor_instance.surface_object = surface
		decor_instance.apply_stacked_offset(true, result.surface_offset)
