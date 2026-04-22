extends GridObject
class_name DecorObject

@export var data: DecorData

var tile_area: Area2D
var body: StaticBody2D
var sprite: Sprite2D
var collider: CollisionShape2D
var detection: CollisionShape2D

var is_placed:= false
var can_place:= true
var pos: Vector2
var current_variant: int

var overlapped_items: Array = []

const INTERACT_PRIORITY = 1

func _ready():
	pass 
	
func _on_build_mode_enabled():
	if tile_area == null:
		return
		
	if is_placed:
		tile_area.monitorable = true
		
func _on_build_mode_disabled():
	if tile_area == null:
		return
		
	if is_placed:
		tile_area.monitorable = false
	
func _process(delta: float) -> void:
	if not is_placed:
		var mouse_pos = get_global_mouse_position()
		
		# Snap to nearest X and Y in 8-pixel increments
		var snapped_pos = Vector2 (
			snapped(mouse_pos.x, 16),
			snapped(mouse_pos.y, 16)
		)
		global_position = snapped_pos

func initialize(decor_data: DecorData):
	
	if decor_data == null:
		push_error("DecorObject: failed to load decor_data")
		return
	
	data = decor_data
		
	sprite = Sprite2D.new()
	add_child(sprite)
	
	create_body()
	create_detection_area()
	
	apply_variant(0)
	
	DecorSystem.build_mode_enabled.connect(_on_build_mode_enabled)
	DecorSystem.build_mode_disabled.connect(_on_build_mode_disabled)
	
func create_body():
	body = StaticBody2D.new()
	add_child(body)
	
	collider = CollisionShape2D.new()
	body.add_child(collider)
	collider.shape = RectangleShape2D.new()
	
func create_detection_area():
	tile_area = Area2D.new()
	add_child(tile_area)
	
	detection = CollisionShape2D.new()
	detection.shape = RectangleShape2D.new()
	tile_area.add_child(detection)
	
	tile_area.set_collision_layer_value(10, true)
	tile_area.set_collision_mask_value(10, true)
	
	tile_area.area_entered.connect(_on_area_entered)
	tile_area.area_exited.connect(_on_area_exited)
	
func apply_variant(variant_no: int):
	current_variant = variant_no
	
	var variant = data.variants[current_variant]
	
	sprite.texture = variant.texture
	
	sprite.offset.y = - (sprite.texture.get_size().y / 2)
	collider.position.y = - (variant.object_size.y / 2)
	
	collider.shape.size = variant.collider_size
	detection.shape.size = variant.detection_size
	
	detection.position.y = - (variant.object_size.y / 2)
	
func set_build_mode():
	
	is_placed = false
	modulate.a = 0.3
	
	body.set_collision_layer_value(6, false)
	body.set_collision_mask_value(2, false)
	
	tile_area.monitoring = true
	
func set_placed_mode():
	is_placed = true
	modulate.a = 1.0
	
	body.set_collision_layer_value(6, true)
	body.set_collision_mask_value(2, true)
	
	tile_area.monitoring = false
	
func _on_area_entered(area):
	if not overlapped_items.has(area):
		overlapped_items.append(area)
		
	modulate = Color(1.0, 0.0, 0.0, 0.5)
	
func _on_area_exited(area):
	if overlapped_items.has(area):
		overlapped_items.erase(area)
		
	modulate = Color(1.0, 1.0, 1.0, 0.5)

func interact(item, context):
	if item is HoeTool:
		if DecorSystem.remove_decor(self):
			play_animation()
	
func get_interaction_score(context):
	return INTERACT_PRIORITY
	
func can_accept_item(item, context) -> bool:
	if item != null:
		if item is HoeTool:
			return true 
	
	return false

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
	
func check_can_place() -> bool:
	if overlapped_items.is_empty():
		return true
	return false
	
func _exit_tree():
	if DecorSystem.build_mode_enabled.connect(_on_build_mode_enabled):
		DecorSystem.build_mode_enabled.disconnect(_on_build_mode_enabled)
	if DecorSystem.build_mode_disabled.connect(_on_build_mode_disabled):
		DecorSystem.build_mode_disabled.disconnect(_on_build_mode_disabled)
