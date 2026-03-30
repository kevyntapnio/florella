extends CharacterBody2D

const SPEED = 150
var facing_direction = Vector2i(0, 1)

@export var tilemap: TileMapLayer
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
var player_global_position
var scroll_locked

func _process(delta):
	update_targeting_visual()
	
func update_targeting_visual():
	var item_data = Hotbar.get_selected_item_data()
	
	var usable_item = null
	
	if item_data is UsableItem:
		usable_item = item_data
	
	var target_tile = TargetingSystem.current_target_coords
	var player_tile = TargetingSystem.player_tile_coords
	
	var objects = GridManager.get_grid_objects(target_tile)

	if objects.is_empty():
		tile_highlight.hide()
		TargetingVisual.update_target(null)
		return
		
	var context = InteractionContext.new(player_tile, target_tile)
	context.tool = usable_item
	
	var best_object = null
	var best_score = -1
	
	for obj in objects:
		if obj.has_method("get_interaction_score") and obj.has_method("can_accept_item"):
			
			var score = obj.get_interaction_score(context)
			
			if score > 0 and obj.can_accept_item(usable_item, context):
				if score > best_score:
					best_score = score
					best_object = obj
	
	var valid = best_object != null
	
	tile_highlight.show_highlight()
	tile_highlight.highlight_tile(target_tile, valid)
	
	TargetingVisual.update_target(best_object)

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
	
	TargetingSystem.player_tile_coords = player_tile_coords
	TargetingSystem.facing_direction = facing_direction
	TargetingSystem.player_global_position = global_position

	TargetingSystem.update_current_target()
		
func _input(event: InputEvent) -> void:
	
	if Input.is_action_just_pressed("interact"):
		try_interact()
		
	if Input.is_action_just_pressed("use_item"):
		
		var item = Hotbar.get_selected_item()
		try_interact()
		
	if Input.is_action_just_pressed("ui_accept"):
		TimeManager.advance_day()
		
	## Hotbar input mapping
	for i in range(1, 10):
		if Input.is_action_just_pressed("hotbar_" + str(i)):
			Hotbar.set_selected_index(i - 1)
			
		if Input.is_action_just_pressed("hotbar_0"):
			Hotbar.set_selected_index(9)
	
	if not scroll_locked:
		if Input.is_action_just_pressed("hotbar_next"):
			Hotbar.change_selected_index(1)
			lock_scroll()
	
		if Input.is_action_just_pressed("hotbar_previous"):
			Hotbar.change_selected_index(-1)
			lock_scroll()
			
func try_interact():
	var item = Hotbar.get_selected_item()
	
	InteractionSystem.handle_interact(item)
		
func lock_scroll():
		scroll_locked = true
		await get_tree().create_timer(0.03).timeout
		scroll_locked = false
	
func _on_interaction_area_area_entered(area: Area2D) -> void:
	
	var object = area.get_parent()
	
	if object is Interactable:
		InteractionSystem.register_interactable(object)
		
	var item = area.get_parent()
	if item != null and item is WorldItem:
		item.start_magnet(self)
		
func _on_interaction_area_area_exited(area: Area2D) -> void:
	
	var interactable_object = area.get_parent()
	
	if interactable_object is Interactable:
		InteractionSystem.unregister_interactable(interactable_object)
		
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
