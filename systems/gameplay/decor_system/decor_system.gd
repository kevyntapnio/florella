extends Node2D

@export var tilemap: TileMapLayer
var initialized:= false
var decor_scene: PackedScene
var ysort: Node2D

var placed_decor = {}

signal build_mode_enabled
signal build_mode_disabled

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
	build_mode_enabled.emit()
	
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
	new_decor.set_build_mode()
	
	decor = new_decor
	
func place_decor() -> bool:
	if decor == null:
		return false
		
	var valid = decor.check_can_place()
	
	if not valid:
		return false
		
	var mouse_pos = get_global_mouse_position()
		
	# Snap to nearest X and Y in 8-pixel increments
	var snapped_pos = Vector2 (
		snapped(mouse_pos.x, 16),
		snapped(mouse_pos.y, 16)
	)
		
	decor.position = snapped_pos
	decor.set_placed_mode()
	InventorySystem.remove_item(decor.data.id, 1)
	
	add_to_placed_decor(snapped_pos)
	
	decor = null
	
	SoundManager.play("wood_placed")
	return true
	
func add_to_placed_decor(snapped_pos):
	
	var id = decor.data.id
	var variant = decor.current_variant
	
	var normalized_pos = Vector2i(snapped_pos/ 16)
	
	placed_decor[normalized_pos] = {
		"id": id,
		"variant": variant
		}

	
func cancel_build_mode():
	if decor:
		decor.queue_free()
	decor = null
	build_mode_disabled.emit()
	
func remove_decor(item_decor: DecorObject) -> bool:
	var stack = ItemStack.new()
	stack.item_data = item_decor.data
	stack.quantity = 1
	
	var pos = item_decor.position
	var normalized_pos = Vector2i(pos / 16)
	
	placed_decor.erase(normalized_pos)
	
	WorldItemSpawner.spawn(stack, pos)
	
	item_decor.queue_free()
	
	SoundManager.play("ui_hover")
	
	return true
	
func get_save_data():
	var save_data = {}
	
	for pos in placed_decor:
		var decor_item = placed_decor[pos]
		var decor_copy = decor_item.duplicate(true)
		
		var key = str(pos.x) + "," + str(pos.y)
		
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
		var pos = Vector2i(parts[0].to_int(), parts[1].to_int())
		
		var id = decor_item.get("id")
		var variant = decor_item.get("variant")
		
		placed_decor[pos] = {
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
		
	for pos in placed_decor:
		var converted_pos = pos * 16
	
		var decor_instance = decor_scene.instantiate()
	
		var data = ItemDatabase.get_item(placed_decor[pos]["id"])
	
		decor_instance.initialize(data)
		decor_instance.set_placed_mode()
		ysort.add_child(decor_instance)
		decor_instance.position = converted_pos
		
func switch_variant():
	if decor == null:
		return
		
	var variants = decor.data.variants
	
	if variants.is_empty():
		return
		
	var size = variants.size()
	
	var new_variant = decor.current_variant + 1
	
	new_variant = new_variant % variants.size()
	
	decor.current_variant = new_variant
	decor.apply_variant(new_variant)
