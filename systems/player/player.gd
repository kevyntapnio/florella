extends CharacterBody2D

const SPEED = 120
var facing_direction = Vector2i(0, 1)

@export var tilemap: TileMapLayer
@export var grid_manager: Node2D
@export var tile_highlight: Node2D

@onready var sprite = $AnimatedSprite2D
@onready var interaction_prompt = $InteractionPrompt
@onready var tile_detector = $TileDetector

const INVALID_COORD = Vector2i(-1, -1)

var nearby_interactables = []
var closest_interactable = null
var focused_interactable = null
var player_tile_coords: Vector2i
var current_target_coords: Vector2i
var current_hovered_coords: Vector2i = INVALID_COORD

func _process(delta):
	update_mouse_target()
	update_current_target()
	
	if current_target_coords == INVALID_COORD:
		tile_highlight.remove_highlight()
	else:
		tile_highlight.show_highlight()
		tile_highlight.highlight_tile(current_target_coords)

func update_mouse_target():
	
	var mouse_pos = get_global_mouse_position()
	var local_pos = tilemap.to_local(mouse_pos)
	var grid_coords = tilemap.local_to_map(local_pos)
	
	if grid_coords != current_hovered_coords:
		current_hovered_coords = grid_coords
		
func _physics_process(delta):

	# Movement
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")

	velocity = direction * SPEED
	move_and_slide()

	if velocity.x > 0:
		facing_direction = Vector2i(1, 0)

		if sprite.animation != "walk_right":
			sprite.play("walk_right")

	elif velocity.x < 0:
		facing_direction = Vector2i(-1,0)
		
		if sprite.animation != "walk_left":
			sprite.play("walk_left")

	elif velocity.y < 0:
		facing_direction = Vector2i(0, -1)
		
		if sprite.animation != "walk_up":
			sprite.play("walk_up")

	elif velocity.y > 0:
		facing_direction = Vector2i(0, 1)
		
		if sprite.animation != "walk_down":
			sprite.play("walk_down")

	else:
		sprite.play("idle_down")
	
	update_player_tile_coords()
	find_closest_interactable()
	update_focused_interactable()
		
func _input(event: InputEvent) -> void:
	
	if Input.is_action_just_pressed("interact"):
		
		if closest_interactable:
			closest_interactable.interact()
	
	if Input.is_action_just_pressed("use_item"):
		if current_target_coords == null:
			return
		
		var target_tile = grid_manager.get_tile_at(current_target_coords)
		var selected_item = InventorySystem.get_selected_item()
		
		if selected_item == null:
			return
			
		selected_item.use(target_tile)
	
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

func update_player_tile_coords():

	var local_pos = tilemap.to_local(global_position)
	player_tile_coords = tilemap.local_to_map(local_pos)
	
func get_tile_in_front():
	
	return player_tile_coords + facing_direction

func update_current_target():
	if current_hovered_coords != INVALID_COORD:
		if grid_manager.get_tile_at(current_hovered_coords):
			current_target_coords = current_hovered_coords
		else:
			current_target_coords = INVALID_COORD
	else:
		current_target_coords = get_tile_in_front()
			
