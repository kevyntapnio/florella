extends SpatialObject
class_name DecorObject

@export var data: DecorData

var body: StaticBody2D
var sprite: Sprite2D
var collider: CollisionShape2D
var light: PointLight2D

var is_placed:= false
var current_variant: int
var is_being_removed:= false

var anchor_cell: Vector2i
var visual_cell: Vector2i

var surface_cells: Array[Vector2i] = []

var is_stacked:= false
var current_stacked: Array[DecorObject] = []
var surface_object: DecorObject = null

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
	
	if data.light_source:
		create_light()
	
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
	sprite.offset.x = - (sprite.texture.get_size().x /2)
	
	collider.position.y = - (variant.object_size.y / 2)
	collider.position.x = - variant.object_size.x / 2
	
	collider.shape.size = variant.collider_size
	
func set_placed_mode():
	is_placed = true
	modulate.a = 1.0
	
	activate_spatial_registration(anchor_cell)
	
	body.set_collision_layer_value(6, true)
	body.set_collision_mask_value(2, true)
	
	if data.has_surface:
		register_surface()
		
	#debug_rect()
		
func register_surface():
	## this function registers buildable surface_area of object
	# based on perceived visual height
	
	var variant = data.variants[current_variant]
	var surface_area = variant.surface_area
	
	# convert height to grid logic
	var height = variant.vertical_height
	var converted_height = height / SpatialLookup.tile_size
	
	# get anchor_cell of surface relative to height of object
	
	var surface_anchor = anchor_cell + converted_height
	
	for x in range(surface_area.x):
		for y in range(surface_area.y):
			var cell = surface_anchor + Vector2i(-x, -y)
			surface_cells.append(cell)
			SurfaceRegistry.register(cell, self)
			
func interact(item, context) -> void:
	if data.light_source:
		print("test")
		if light.enabled:
			light.enabled = true
		else:
			light.enabled = false
		
	if not can_accept_item(item, context):
		return
		
	if not current_stacked.is_empty():
		return
		
	if is_being_removed: 
		return

	is_being_removed = true
	
	if item is HoeTool and DecorSystem.remove_decor(self):
		play_animation()
	
func get_interaction_score(context) -> int:
	if is_stacked:
		return 20
	if not current_stacked.is_empty():
		return 0
	return INTERACT_PRIORITY
	
func can_accept_item(item, context) -> bool:
	if item is HoeTool:
		return true
		
	return false

func set_preview_modulate(is_valid: bool):
	if is_valid: 
		modulate = Color(1.0, 1.0, 1.0, 0.3)
	else:
		modulate = Color(1.0, 0.0, 0.0, 0.5)

func set_targeted(is_targeted: bool):
	if is_targeted:
		modulate = Color(1.3, 1.3, 1.3)
	else:
		modulate = Color(1.0, 1.0, 1.0)
	
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
		
func apply_stacked_ysort(surface, offset):

	var base_offset = - sprite.texture.get_size().y / 2.0
	sprite.offset.y = base_offset - offset

func apply_regular_ysort():
	sprite.offset.y = - (sprite.texture.get_size().y / 2.0)
	
func register_as_stacked(surface):
	if not surface.current_stacked.has(self):
		surface.current_stacked.append(self)
		
	is_stacked = true
	surface_object = surface
	
func _exit_tree():
	super()
	for cell in surface_cells:
		SurfaceRegistry.unregister(cell, self)
	
	if surface_object and is_instance_valid(surface_object):
		if surface_object.current_stacked.has(self):
			surface_object.current_stacked.erase(self)
	
func debug_rect():
	var occupied = get_occupied_cells(anchor_cell)
	
	for c in occupied:
		var rect = ColorRect.new()
		add_child(rect)
		rect.size = Vector2(16, 16)
		rect.global_position = SpatialLookup.get_world_position(c)
		rect.modulate = Color(0.0, 0.681, 0.424, 0.5)
		
	var origin_rect = ColorRect.new()
	add_child(origin_rect)
	origin_rect.global_position = global_position
	#SpatialLookup.get_world_position(anchor_cell)
	origin_rect.size = Vector2(4, 4)
	origin_rect.modulate = Color.BLACK
	
func create_light():
	var light_texture = load("res://test_objects/light_source/light_glow.tres")
	
	light = PointLight2D.new()
	add_child(light)
	light.texture = light_texture
	light.position = self.position
	light.enabled = false
	light.energy = 0.8
	
	create_interactable_area()

func create_interactable_area():
	var interaction_area = Area2D.new()
	add_child(interaction_area)
	
	var variant = data.variants[current_variant]
	
	var area = CollisionShape2D.new()
	interaction_area.add_child(area)
	
	area.shape = RectangleShape2D.new()
	area.shape.size = variant.collider_size 

	area.position.y = - sprite.texture.get_size().y / 2
	
	interaction_area.set_collision_layer_value(3, true)
	
