extends Node2D

class_name WorldItem

@onready var sprite = $Sprite2D

var stack: ItemStack
var id: String
var quantity: int
var is_magnetized: bool = false
var player: Node2D
var velocity: Vector2
var is_spawning := true
var magnet_delay := 0.12
var can_magnetize := false
	
func initialize(new_stack: ItemStack):
	velocity = Vector2(
		randf_range(-50, 50),
		-120
	)
	scale = Vector2(0.05, 0.05)
	
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(0.8, 0.8), 0.15) \
		.set_trans(Tween.TRANS_BACK) \
		.set_ease(Tween.EASE_OUT)
		
	stack = new_stack
	
	quantity = stack.quantity
	
	if sprite:
		sprite.texture = stack.item_data.icon
	
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
			var leftover = InventorySystem.add_stack(stack)
			queue_free()
			
			if leftover.quantity > 0:
				stack = leftover
				
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
		
