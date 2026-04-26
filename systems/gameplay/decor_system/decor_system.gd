extends Node2D

@export var tilemap: TileMapLayer
var initialized:= false
var decor_scene: PackedScene
var ysort: Node2D

var placed_decor = {}

var decor = null
var debug_print:= false

signal load_finished

func _ready():
	decor_scene = load("res://test_objects/decor_item/decor.tscn")
	
	if decor_scene == null:
		push_error("DecorSystem: decor_scene not loaded on _ready")

func set_tilemap(map, ysort_ref):
	tilemap = map
	initialized = true
	ysort = ysort_ref
	
func initialize_build_mode(item: DecorData):
	if decor != null:
		decor.queue_free()
		
	if not initialized:
		push_error("DecorSystem ERROR: tilemap is not set. call initialize in Level node")
		return
		
	if ysort == null:
		push_error("DecorSystem ERROR: ysort_world not set. call initialize in Level node")
		return
	
	var new_decor = decor_scene.instantiate()
	new_decor.initialize(item)
	ysort.add_child(new_decor)
	
	decor = new_decor
	
func _process(_delta: float) -> void:
	## If currently in build_mode
	if decor != null:
		
		get_decor_position()
		set_preview_modulate()
		
		#var preview_position = SpatialLookup.get_world_position(TargetingSystem.current_target_cell)
		#decor.position = preview_position
		
func get_decor_position():
	var context = PlacementContext.new()
	var target_cell = get_target_cell()
	
	context.target_cell = target_cell
	context.occupied_cells = decor.get_occupied_cells(target_cell)
	context.data = decor.data
	
	var preview_position = SpatialLookup.get_world_position(TargetingSystem.current_target_cell)
	var has_surface = PlacementValidator.check_overlap(context)
	
	var surface_info = PlacementValidator.get_surface_offset(context)
	var surface = surface_info.get("surface")
	
	if has_surface:
		if surface != null:
			var offset = surface_info.get("offset")
			decor.apply_stacked_ysort(surface, offset)
			preview_position.y = surface.position.y + 1.0
			
	else:
		decor.apply_regular_ysort()
	
	decor.position = preview_position
		
func set_preview_modulate():
	
	decor.set_preview_modulate(validate_placement())
	
func get_target_cell():
	
	## target_cell is adjusted to compensate for node origin sitting at bottom-right of decor_object
	## occupancy must be calculated based on 1 tile above, 1 tile left of origin
	
	var hovered_cell = TargetingSystem.current_target_cell
	var target_cell = hovered_cell + Vector2i(-1, -1)
	
	return target_cell
	
func place_decor() -> bool:
	if decor == null:
		return false
		
	var valid = validate_placement()
	
	if not valid:
		return false
	
	var visual_cell = TargetingSystem.current_target_cell
	var target_cell = get_target_cell()
	
	decor.anchor_cell = target_cell
	decor.visual_cell = visual_cell
	#decor.position = SpatialLookup.get_world_position(visual_cell)
	get_decor_position()
	finalize_surface_placement()
	
	decor.set_placed_mode()
	InventorySystem.remove_item(decor.data.id, 1)
	
	add_to_placed_decor()
	
	decor = null
	
	SoundManager.play("wood_placed")
	return true
	
func finalize_surface_placement():
	if not decor:
		return
		
	var context = PlacementContext.new()
	context.data = decor.data
	context.target_cell = get_target_cell()
	context.occupied_cells = decor.get_occupied_cells(get_target_cell())
	
	if PlacementValidator.check_overlap(context):
		var info = PlacementValidator.get_surface_offset(context)
		var surface = info.get("surface")
		
		decor.register_as_stacked(surface)
		
		decor.position.y = surface.position.y + 1
		
func validate_placement() -> bool:
	
	if decor == null:
		return false
	
	var target_cell = get_target_cell()
	
	var context = PlacementContext.new()
	context.data = decor.data
	context.occupied_cells = decor.get_occupied_cells(target_cell)
	context.target_cell = target_cell
		
	return PlacementValidator.can_place(context)
	
func add_to_placed_decor():
	## visual_cell represents where the object visually sits in the grid
	## anchor_cell represents the logical bottom-right anchor 
	## anchor_cell is offset by tile_above to accommodate effect of coordinate semantics to node origin
	
	var id = decor.data.id
	var variant = decor.current_variant
	var anchor_cell = decor.anchor_cell
	var visual_cell = decor.visual_cell
	var is_stacked = decor.is_stacked
	
	var decor_info = {
		"anchor_cell": anchor_cell,
		"id": id,
		"variant": variant,
		"is_stacked": is_stacked
		}
		
	if not placed_decor.has(visual_cell):
		placed_decor[visual_cell] = []
		
	placed_decor[visual_cell].append(decor_info)
	
func cancel_build_mode() -> void:
	if decor:
		decor.queue_free()
	decor = null
	
func refresh_build_mode(item_data: DecorData) -> void:
	cancel_build_mode()
	initialize_build_mode(item_data)
	
func remove_decor(item_decor: DecorObject) -> bool:
	
	var visual_cell = item_decor.visual_cell
	var anchor_cell = item_decor.anchor_cell
	
	if not placed_decor.has(visual_cell):
		return false
		
	var stack_at_tile = placed_decor[visual_cell]
	
	for i in range(stack_at_tile.size()):
		var entry = stack_at_tile[i]
		
		if entry["anchor_cell"] == anchor_cell:
			stack_at_tile.remove_at(i)
			break
		
	if stack_at_tile.is_empty():
		placed_decor.erase(visual_cell)
	
	var pos = SpatialLookup.get_world_position(visual_cell)
	var stack = ItemStack.new()
	stack.item_data = item_decor.data
	stack.quantity = 1
	
	WorldItemSpawner.spawn(stack, pos)
	
	item_decor.queue_free()
	SoundManager.play("ui_hover")
	
	return true
	
func get_save_data():
	var save_data = {}
	
	for visual_cell in placed_decor:
		var stacked_at_tile = placed_decor[visual_cell]
		var key = str(visual_cell.x) + "," + str(visual_cell.y)
		
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
		var visual_cell = Vector2i(parts[0].to_int(), parts[1].to_int())
		
		var items_at_tile = data[key]
		
		var parsed_list = []
		
		for decor_item in items_at_tile:
		
			var id = decor_item.get("id")
			var variant = decor_item.get("variant")
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
		
		placed_decor[visual_cell] = parsed_list
		load_finished.emit()
		
func spawn_decor():
	
	if not is_instance_valid(ysort):
		push_error("DecorSystem ERROR: invalid ysort")
		return
		
	if decor_scene == null:
		push_error("DecorSystem ERROR: decor_scene failed to load")
		return
		
	var spawned_instances: Array[DecorObject] = []
	
	for visual_cell in placed_decor:
		var stack_at_tile = placed_decor[visual_cell]
		
		for decor_item in stack_at_tile:
			var decor_instance = decor_scene.instantiate()
			
			var data = ItemDatabase.get_item(decor_item["id"])
			var variant = decor_item["variant"]
				
			decor_instance.current_variant = variant
			decor_instance.anchor_cell = decor_item["anchor_cell"]
			decor_instance.visual_cell = visual_cell
			decor_instance.is_stacked = decor_item["is_stacked"]
			decor_instance.initialize(data)
				
			ysort.add_child(decor_instance)
				
			decor_instance.position = SpatialLookup.get_world_position(visual_cell)
				
			decor_instance.set_placed_mode()
				
			spawned_instances.append(decor_instance)
		
	#await get_tree().process_frame
	
	for decor_instance in spawned_instances:
		if decor_instance.is_stacked:
			apply_stacked_offset(decor_instance)
			
func apply_stacked_offset(decor_instance: DecorObject):
		
	var context = PlacementContext.new()
	context.target_cell = decor_instance.anchor_cell
	context.data = decor_instance.data
	context.occupied_cells = decor_instance.get_occupied_cells(decor_instance.anchor_cell)
	
	if PlacementValidator.check_overlap(context):
		var info = PlacementValidator.get_surface_offset(context)
		
		var surface = info.get("surface")
		
		if surface != null:
			decor_instance.position.y = surface.position.y + 1.0
			decor_instance.register_as_stacked(surface)
			decor_instance.apply_stacked_ysort(surface, info.get("offset"))
		
func switch_variant():
	if decor == null:
		return
		
	var variants = decor.data.variants
	
	if variants.is_empty():
		return
	
	var new_variant = decor.current_variant + 1
	
	new_variant = new_variant % variants.size()
	
	decor.current_variant = new_variant
	decor.apply_variant(new_variant)
	
	
