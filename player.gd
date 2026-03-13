extends CharacterBody2D

const SPEED = 120
var facing_direction = "down"

@onready var sprite = $AnimatedSprite2D
@onready var interaction_prompt = $InteractionPrompt

var nearby_interactables = []
var closest_interactable = null
var focused_interactable = null
var closest_tile = null
var nearby_tiles = []

## added for debugging
func _ready():
	print(InventorySystem)

func _physics_process(delta):
	
	find_closest_interactable()
	update_focused_interactable()
	find_closest_tile()

	# Movement
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")

	velocity = direction * SPEED
	move_and_slide()

	if velocity.x > 0:
		facing_direction = "right"

		if sprite.animation != "walk_right":
			sprite.play("walk_right")

	elif velocity.x < 0:
		facing_direction = "left"

		if sprite.animation != "walk_left":
			sprite.play("walk_left")

	elif velocity.y < 0:
		facing_direction = "up"

		if sprite.animation != "walk_up":
			sprite.play("walk_up")

	elif velocity.y > 0:
		facing_direction = "down"

		if sprite.animation != "walk_down":
			sprite.play("walk_down")

	else:
		sprite.play("idle_down")
		
	# OBJECT INTERACTION
	
	if Input.is_action_just_pressed("interact"):
		
		if closest_interactable:
			closest_interactable.interact()
	
	# PLANTING
	
	if Input.is_action_just_pressed("use_item"):
		if closest_tile == null:
			return
		
		var selected_item = InventorySystem.get_selected_item()
		
		if selected_item == null:
			return
			
		selected_item.use(closest_tile) 
	
func _on_interaction_area_area_entered(area: Area2D) -> void:
	
	if area is Interactable:
		var interactable_object = area.get_parent()
		nearby_interactables.append(interactable_object)
		
func _on_interaction_area_area_exited(area: Area2D) -> void:
	
	if area is Interactable:
		var interactable_object = area.get_parent()
		nearby_interactables.erase(interactable_object)
		
		find_closest_interactable()
		update_focused_interactable()
		
func find_closest_interactable():
	
	var closest_object = null
	var current_smallest_distance = INF
	
	for object in nearby_interactables:
		var distance = global_position.distance_to(object.global_position)
		
		if distance < current_smallest_distance:
			current_smallest_distance = distance
			closest_object = object
			
	closest_interactable = closest_object

func update_focused_interactable():

	if closest_interactable != focused_interactable:
		
		if focused_interactable: 
			focused_interactable.on_focus_exited()
			
		focused_interactable = closest_interactable
		
		if focused_interactable:
			focused_interactable.on_focus_entered()
			
			var action = focused_interactable.get_interaction_action()
			print (action)
			
			interaction_prompt.show()
		else:
			interaction_prompt.hide()

func _on_tile_detector_area_entered(area: Area2D) -> void:

	var farm_tile = area.get_parent()
	nearby_tiles.append(farm_tile)
	
func _on_tile_detector_area_exited(area: Area2D) -> void:
	
	var farm_tile = area.get_parent()
	nearby_tiles.erase(farm_tile)
	
	find_closest_tile()
	
func find_closest_tile():
	
	var closest_object = null
	var smallest_distance = INF
	
	for farm_tile in nearby_tiles:
		var distance = global_position.distance_to(farm_tile.global_position)
		
		if distance < smallest_distance:
			smallest_distance = distance
			closest_object = farm_tile
	
	closest_tile = closest_object
	
