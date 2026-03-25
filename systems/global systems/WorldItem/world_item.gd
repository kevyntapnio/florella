extends Node2D

class_name WorldItem

@onready var sprite = $Sprite2D
var id: String
var quantity: int
var is_magnetized: bool = false
var player: Node2D
var velocity: Vector2
var is_spawning := true
var magnet_delay := 0.08
var can_magnetize := false
	
func initialize(item_id: String, item_quantity: int):
	velocity = Vector2(
		randf_range(-50, 50),
		-120
	)
	scale = Vector2(0.6, 0.6)
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1, 1), 0.15) \
		.set_trans(Tween.TRANS_BACK) \
		.set_ease(Tween.EASE_OUT)
		
		
	id = item_id
	quantity = item_quantity
	print(quantity)
	
	var item_data = ItemDatabase.get_item(id)
	
	if item_data == null:
		print("WORLD_ITEM item_data not found")
		return
		
	sprite.texture = item_data.icon
	
func start_magnet(target: Node2D):
	player = target
	
	if is_magnetized:
		return
		
	player = target
	is_magnetized = true
	
func _physics_process(delta: float) -> void:
	if !is_instance_valid(player):
		return
		
	if is_magnetized and can_magnetize:
		var direction = (player.global_position - global_position).normalized()
		var distance = global_position.distance_to(player.global_position)
		
		var t = 1.0 - clamp(distance / 120.0, 0.0, 1.0)
		t = t * t
		var speed = lerp(150, 600, t)
		
		global_position += direction * speed * delta
		
		if global_position.distance_to(player.get_global_position()) <= 5.0:
			InventorySystem.add_item(id, quantity) # refactor Inventory later so this function can return a bool
			queue_free()
		return

	if is_spawning:
		velocity.y += 1000 * delta # gravity
		
		global_position += velocity * delta
		
		if velocity.y > 0:
			is_spawning = false
		return
		
	if !can_magnetize:
		magnet_delay -= delta
		
		if magnet_delay <= 0:
			can_magnetize = true
		return
		
