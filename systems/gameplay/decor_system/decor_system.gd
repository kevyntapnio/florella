extends Node2D

@export var tilemap: TileMapLayer
var initialized:= false
var decor_scene: PackedScene
var ysort: Node2D

var placed_decor = {}

var decor = null

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
		return
		
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
		
func get_decor_position():
	var context = PlacementContext.new()
	var target_cell = get_target_cell()
	
	context.target_cell = target_cell
	context.occupied_cells = decor.get_occupied_cells(target_cell)
	context.data = decor.data
	
	var has_overlap = PlacementValidator.check_overlap(context)
	
	var preview_position = SpatialLookup.get_world_position(TargetingSystem.current_target_cell)
	decor.position = preview_position
	
	var offset = Vector2(0, 0)
	if has_overlap:
		offset = PlacementValidator.get_adjusted_pos(context)
		decor.stacked = true
	else:
		decor.stacked = false
	
	decor.apply_stacked_ysort(offset)
		
func set_preview_modulate():
	
	decor.set_preview_modulate(validate_placement())
	
func get_target_cell():
	var hovered_cell = TargetingSystem.current_target_cell
	var target_cell = hovered_cell + Vector2i(0, -1)
	
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
	decor.position = SpatialLookup.get_world_position(visual_cell)
	
	decor.set_placed_mode()
	InventorySystem.remove_item(decor.data.id, 1)
	
	add_to_placed_decor()
	
	decor = null
	
	SoundManager.play("wood_placed")
	return true
	
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
	## anchor_cell represnets the logical bottom-right anchor 
	## anchor_cell is offset by tile_above to accommodate effect of coordinate semantics to node origin
	
	var id = decor.data.id
	var variant = decor.current_variant
	var anchor_cell = decor.anchor_cell
	var visual_cell = decor.visual_cell
	
	placed_decor[visual_cell] = {
		"anchor_cell": anchor_cell,
		"id": id,
		"variant": variant
		}
	
func cancel_build_mode():
	if decor:
		decor.queue_free()
	decor = null
	
func remove_decor(item_decor: DecorObject) -> bool:
	var stack = ItemStack.new()
	stack.item_data = item_decor.data
	stack.quantity = 1
	
	var visual_cell = item_decor.visual_cell
	var pos = SpatialLookup.get_world_position(visual_cell)
	
	placed_decor.erase(visual_cell)
	
	WorldItemSpawner.spawn(stack, pos)
	
	item_decor.queue_free()
	
	SoundManager.play("ui_hover")
	
	return true
	
func get_save_data():
	var save_data = {}
	
	for visual_cell in placed_decor:
		var decor_item = placed_decor[visual_cell]
		var decor_copy = decor_item.duplicate(true)
		
		var key = str(visual_cell.x) + "," + str(visual_cell.y)
		
		var anchor_cell = decor_copy["anchor_cell"]
		var anchor_key = str(anchor_cell.x) + "," + str(anchor_cell.y)
		decor_copy["anchor_cell"] = anchor_key
		
		save_data[key] = decor_copy
		
	return save_data
	
func load_from_data(data):
	if data == null: 
		push_error("DecorSystem ERROR: failed to load data from saved file")
		return
		
	placed_decor.clear()
	
	for key in data: 
		var decor_item = data[key]
		
		var parts = key.split(",")
		var visual_cell = Vector2i(parts[0].to_int(), parts[1].to_int())
		
		var id = decor_item.get("id")
		var variant = decor_item.get("variant")
		
		var anchor_str = decor_item.get("anchor_cell")
		var a_parts = anchor_str.split(",")
		var anchor_cell = Vector2i(a_parts[0].to_int(), a_parts[1].to_int())
		
		placed_decor[visual_cell] = {
			"anchor_cell": anchor_cell,
			"id": id,
			"variant": variant
		}
	
func spawn_decor():
	
	if not is_instance_valid(ysort):
		push_error("DecorSystem ERROR: invalid ysort")
		return
		
	if decor_scene == null:
		push_error("DecorSystem ERROR: decor_scene failed to load")
		return
		
	for visual_cell in placed_decor:
		var decor_item = placed_decor[visual_cell]
		var decor_instance = decor_scene.instantiate()
	
		var data = ItemDatabase.get_item(decor_item["id"])
		var variant = decor_item["variant"]
		
		decor_instance.current_variant = variant
		decor_instance.anchor_cell = decor_item["anchor_cell"]
		decor_instance.visual_cell = visual_cell
		decor_instance.initialize(data)
		
		ysort.add_child(decor_instance)
		
		decor_instance.position = SpatialLookup.get_world_position(visual_cell)
		decor_instance.set_placed_mode()
		
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
	
	
