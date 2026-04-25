extends SpatialObject
class_name DecorObject

@export var data: DecorData

var body: StaticBody2D
var sprite: Sprite2D
var collider: CollisionShape2D

var is_placed:= false
var current_variant: int
var is_being_removed:= false

var anchor_cell: Vector2i
var visual_cell: Vector2i

var stacked:= false

const INTERACT_PRIORITY = 1
	
func initialize(decor_data: DecorData):
	
	if decor_data == null:
		push_error("DecorObject: failed to load decor_data")
		return
	
	data = decor_data
		
	sprite = Sprite2D.new()
	add_child(sprite)
	
	create_body()
	
	apply_variant(current_variant)
	
func create_body():
	body = StaticBody2D.new()
	add_child(body)
	
	collider = CollisionShape2D.new()
	body.add_child(collider)
	collider.shape = RectangleShape2D.new()
	
func apply_variant(variant_no: int):
	current_variant = variant_no
	
	if current_variant < 0 or current_variant >= data.variants.size():
		push_error("DecorObject ERROR: invalid variant index")
		return
		
	var variant = data.variants[current_variant]
	
	sprite.texture = variant.texture
	
	sprite.offset.y = - (sprite.texture.get_size().y / 2)
	
	collider.position.y = - (variant.object_size.y / 2)
	
	collider.shape.size = variant.collider_size
	
func set_placed_mode():
	is_placed = true
	modulate.a = 1.0
	
	activate_spatial_registration(anchor_cell)
	
	body.set_collision_layer_value(6, true)
	body.set_collision_mask_value(2, true)
	
	debug_rect()

func interact(item, context):
	if is_being_removed: 
		return
		
	is_being_removed = true
	
	if item is HoeTool and DecorSystem.remove_decor(self):
			play_animation()
	
func get_interaction_score(context):
	return INTERACT_PRIORITY
	
func can_accept_item(item, context) -> bool:
	return item is HoeTool
	
func set_preview_modulate(is_valid: bool):
	if is_valid: 
		modulate = Color(1.0, 1.0, 1.0, 0.3)
	else:
		modulate = Color(1.0, 0.0, 0.0, 0.5)

func set_targeted(is_targeted: bool):
	if is_targeted:
		modulate = Color(1.2, 1.2, 1.2)
	
func play_animation():
	var tween = create_tween()

	tween.tween_property(self, "scale", Vector2(1.2, 0.8), 0.08) \
		.set_trans(Tween.TRANS_SINE) \
		.set_ease(Tween.EASE_OUT)
	
	tween.tween_property(self, "scale", Vector2(0.9, 1.2), 0.08) \
		.set_trans(Tween.TRANS_SINE) \
		.set_ease(Tween.EASE_IN)
		
	tween.tween_property(self, "scale", Vector2(1, 1), 0.05) 
	
	return tween
	
func get_occupied_cells(target_cell):
	
	var size = data.variants[current_variant].object_size
	var size_in_tiles = Vector2i(size / SpatialLookup.tile_size)
	
	var occupied_cells: Array[Vector2i] = []
	
	for x in range(size_in_tiles.x):
		for y in range(size_in_tiles.y):
			var cell = target_cell + Vector2i(-x, -y)
			occupied_cells.append(cell)
			
	return occupied_cells
	
func get_surface_area():
	if not data:
		push_error("DecorObject ERROR: Failed to load data:", self)
		return 
		
	if data.has_surface:
		return data.variants[current_variant].surface_area
	
func get_vertical_height():
	if not data:
		push_error("DecorObject ERROR: Failed to load data:", self)
		return 
		
	if data.has_surface:
		return data.variants[current_variant].vertical_height
		
func apply_stacked_ysort(offset):
	sprite.offset.y = - (sprite.texture.get_size().y / 2) - offset.y
	
func debug_rect():
	var occupied = get_occupied_cells(anchor_cell)
	
	for c in occupied:
		var rect = ColorRect.new()
		add_child(rect)
		rect.size = Vector2(16, 16)
		rect.global_position = SpatialLookup.get_world_position(c)
		rect.modulate = Color(0.0, 0.681, 0.424, 0.5)
