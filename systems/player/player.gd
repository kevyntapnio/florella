extends CharacterBody2D

const SPEED = 120
var facing_direction = "down"

@export var tilemap: TileMapLayer
@export var grid_manager: Node2D
@export var tile_highlight: Node2D

@onready var sprite = $AnimatedSprite2D
@onready var interaction_prompt = $InteractionPrompt
@onready var tile_detector = $TileDetector

var nearby_interactables = []
var closest_interactable = null
var focused_interactable = null
var closest_tile = null
var nearby_tiles = []
var current_hovered_tile

func _process(delta):
	
	var mouse_pos = get_global_mouse_position()
	var local_pos = tilemap.to_local(mouse_pos)
	var grid_coords = tilemap.local_to_map(local_pos)
	
	var new_hovered_tile = grid_manager.get_tile_at(grid_coords)
	
	var farm_tiles = get_tree().get_nodes_in_group("farm_tiles")
	
	if new_hovered_tile != current_hovered_tile:
		
		current_hovered_tile = new_hovered_tile
		tile_highlight.highlight_tile(grid_coords)

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
		update_tile_detector()

		if sprite.animation != "walk_right":
			sprite.play("walk_right")

	elif velocity.x < 0:
		facing_direction = "left"
		update_tile_detector()
		
		if sprite.animation != "walk_left":
			sprite.play("walk_left")

	elif velocity.y < 0:
		facing_direction = "up"
		update_tile_detector()
		
		if sprite.animation != "walk_up":
			sprite.play("walk_up")

	elif velocity.y > 0:
		facing_direction = "down"
		update_tile_detector()
		
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
	
	var interactable_object = area.get_parent()
	
	if interactable_object is Interactable:

		print(area)
		print(area.get_parent())
		nearby_interactables.append(interactable_object)
		
func _on_interaction_area_area_exited(area: Area2D) -> void:
	
	var interactable_object = area.get_parent()
		
	if interactable_object is Interactable:
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
	
func update_tile_detector():
	match facing_direction:
		"up":
			tile_detector.position = Vector2(0, -32)
		"down":
			tile_detector.position = Vector2(0, 32)
		"left":
			tile_detector.position = Vector2(-32, 0)
		"right":
			tile_detector.position = Vector2(32, 0)
			
