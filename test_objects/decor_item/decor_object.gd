class_name DecorObject
extends SpatialObject

var current_variant: int = 0
var data: DecorData

var body: StaticBody2D
var sprite: Sprite2D
var collider: CollisionShape2D

var is_being_removed:= false
var is_placed:= false
var is_stacked:= false

var anchor_cell: Vector2i
var origin_cell: Vector2i
var surface_object: DecorObject
var occupied_cells: Array[Vector2i] = []

const INTERACT_PRIORITY = 10

func initialize(decor_data: DecorData):
	if decor_data == null:
		return
	
	data = decor_data
	
	create_body()
	create_sprite()
	apply_variant_texture(current_variant)
	
func create_body() -> void:
	body = StaticBody2D.new()
	add_child(body)
	
func create_sprite() -> void:
	sprite = Sprite2D.new()
	add_child(sprite)
	
func apply_variant_texture(variant_index: int) -> void:
	var variant = data.variants[variant_index] 
	
	sprite.texture = variant.texture
	
	## We offset the sprite up to handle y-sorting
	## Sprite is then offset to the left to accommodate occupancy rules: See docs on Coordinate Systems
	
	var sprite_size = sprite.texture.get_size()
	sprite.offset.x = - sprite_size.x / 2
	sprite.offset.y = - sprite_size.y /2
	
func apply_stacked_offset(stacked: bool, offset: int) -> void:
	## this function is called to accomodate visual offset for decor stacking
	## received value "offset" pertains to surface_object's vertical height

	var default_y_offset = - (sprite.texture.get_size().y / 2)
	var final_offset: int 
	
	if stacked:
		final_offset = default_y_offset - offset
	else:
		final_offset = default_y_offset
		
	sprite.offset.y = final_offset
	
	if collider:
		collider.position.y = - (data.variants[current_variant].object_size.y / 2)
		
func get_occupied_cells(cell: Vector2i) -> Array[Vector2i]:
	if cell == null:
		return []
		
	var size = data.variants[current_variant].object_size
	var size_in_tiles = Vector2i(size / SpatialLookup.tile_size)
	
	var occupied_cells: Array[Vector2i] = []
	
	for x in range(size_in_tiles.x):
		for y in range(size_in_tiles.y):
			var c = cell + Vector2i(-x, -y)
			occupied_cells.append(c)
			
	return occupied_cells
	
func register_surface():
	## this function registers buildable surface_area of object
	# based on perceived visual height
	if occupied_cells.is_empty():
		return
		
	for cell in occupied_cells:
		SurfaceRegistry.register(cell, self)
			
func set_placed_mode(variant_index: int, is_currently_stacked: bool, surface_offset: int) -> void:

	is_placed = true
	is_stacked = is_currently_stacked
	
	apply_variant_texture(variant_index)
	apply_colliders(variant_index, is_stacked, surface_offset)
	current_variant = variant_index
	
	occupied_cells = get_occupied_cells(anchor_cell)
	activate_spatial_registration(anchor_cell)
		
	modulate.a = 1.0
	
	if data.has_surface:
		register_surface()
			
func apply_colliders(variant_index: int, is_currently_stacked: bool, offset: int) -> void:
	
	var variant = data.variants[variant_index]
	
	collider = CollisionShape2D.new()
	collider.shape = RectangleShape2D.new()
	body.add_child(collider)
	
	collider.shape.size = variant.collider_size
	collider.position.x = - (variant.object_size.x / 2)
	collider.position.y = - (variant.object_size.y / 2)

	
	body.set_collision_layer_value(6, true)
	body.set_collision_mask_value(2, true)
	
	if is_stacked:
		apply_stacked_offset(true, offset)
		
func interact(request: InteractionRequest) -> bool:
	if not request.selected_item_data is HoeTool:
		return false
	
	DecorSystem.request_removal(self)
	return true
	
func get_interaction_score(context):
	if is_stacked: 
		return 20
		
	### NOTE: temporary until interaction_zone registry is implemented
	if data.placement_behavior == DecorData.PlacementBehavior.WALL_ITEM:
		return 1
	else:
		return INTERACT_PRIORITY
	
func get_interaction_zone():
	return get_total_interactable_area()
	
func can_accept_item(request):
	return true

func is_currently_interactable():
	return true
	
func get_total_interactable_area():
	if not is_placed:
		return
		
	var offset_zone: Array[Vector2i] = []
	
	if is_stacked:
		for cell in occupied_cells:
			var adjusted = cell + Vector2i.UP
			offset_zone.append(adjusted)
		
	if data.placement_behavior == DecorData.PlacementBehavior.WALL_ITEM:
		for cell in occupied_cells:
			var adjusted = cell + Vector2i(0, 2)
			offset_zone.append(adjusted)
	
	return occupied_cells + offset_zone
	
func activate_spatial_registration(anchor_cell):
	var interactable_zone = get_total_interactable_area()
	
	for c in interactable_zone:
		SpatialLookup.register_spatial_object(c, self)
	
func _exit_tree():
	super()
	if occupied_cells.is_empty():
		return
	
	for cell in occupied_cells:
		if SurfaceRegistry.surface_objects.has(cell):
			SurfaceRegistry.unregister(cell, self)
	
	for cell in get_total_interactable_area():
		SpatialLookup.unregister_spatial_object(cell, self)
