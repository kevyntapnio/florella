extends CharacterBody2D

const SPEED = 120
var facing_direction = Vector2i(0, 1)

@export var tilemap: TileMapLayer
@export var grid_manager: Node2D
@export var tile_highlight: Node2D
@export var targeting_system: Node2D
@export var interaction_system: Node2D

@onready var sprite = $AnimatedSprite2D
@onready var interaction_prompt = $InteractionPrompt
@onready var tile_detector = $TileDetector

const INVALID_COORD = Vector2i(-1, -1)

var nearby_interactables = []
var closest_interactable = null
var focused_interactable = null
var player_tile_coords: Vector2i
var current_target_coords: Vector2i
var player_global_position

func _process(delta):
	
	var target_tile = grid_manager.get_grid_object(targeting_system.current_target_coords)

	if target_tile != null:
		tile_highlight.show_highlight()
		tile_highlight.highlight_tile(targeting_system.current_target_coords)
	else:
		tile_highlight.remove_highlight()

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
	
	targeting_system.player_tile_coords = player_tile_coords
	targeting_system.facing_direction = facing_direction
	targeting_system.player_global_position = global_position

	targeting_system.update_current_target()
		
func _input(event: InputEvent) -> void:
	
	if Input.is_action_just_pressed("interact"):
		interaction_system.handle_interact(null)
		
	if Input.is_action_just_pressed("use_item"):
		
		var item = Hotbar.get_selected_item()
		interaction_system.handle_interact(item)
		
	if Input.is_action_just_pressed("ui_accept"):
		TimeManager.advance_day()
		
	## Hotbar input mapping
	for i in range(1, 10):
		if Input.is_action_just_pressed("hotbar_" + str(i)):
			Hotbar.set_selected_index(i - 1)
			
		if Input.is_action_just_pressed("hotbar_0"):
			Hotbar.set_selected_index(9)
	
	if Input.is_action_just_pressed("hotbar_next"):
		Hotbar.change_selected_index(1)
		print("Scroll input triggered")
	
	if Input.is_action_just_pressed("hotbar_previous"):
		Hotbar.change_selected_index(-1)
		
func _on_interaction_area_area_entered(area: Area2D) -> void:
	
	var interactable_object = area.get_parent()
	
	if interactable_object is Interactable:
		interaction_system.register_interactable(interactable_object)
		
func _on_interaction_area_area_exited(area: Area2D) -> void:
	
	var interactable_object = area.get_parent()
	
	if interactable_object is Interactable:
		interaction_system.unregister_interactable(interactable_object)
		
	find_closest_interactable()
		
func find_closest_interactable():
	
	var closest_object = null
	var current_smallest_distance = INF
	
	for object in nearby_interactables:
		var distance = global_position.distance_to(object.global_position)
		
		if distance < current_smallest_distance:
			current_smallest_distance = distance
			closest_object = object
			
	closest_interactable = closest_object

func update_player_tile_coords():

	var local_pos = tilemap.to_local(global_position)
	player_tile_coords = tilemap.local_to_map(local_pos)
	
func _ready():
	pass
