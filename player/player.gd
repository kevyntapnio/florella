extends CharacterBody2D

signal player_ready

const SPEED = 150
var facing_direction = Vector2i(0, 1)

@onready var interaction_area = $InteractionArea

@export var tilemap: TileMapLayer
@export var tile_highlight: Node2D
@export var scene_controller: Node

@onready var sprite = $AnimatedSprite2D
@onready var interaction_prompt = $InteractionPrompt
@onready var tile_detector = $TileDetector


const INVALID_COORD = Vector2i(-1, -1)

var interaction_system: Node
var targeting_system: TargetingSystem

var focused_interactable = null
var player_tile_coords: Vector2i
var player_global_position
var scroll_locked
var reactive_objects: Dictionary = {}

var build_mode:= false
var just_spawned = true
var initialized:= false

var current_decor_id: String = ""

func _ready() -> void:
	
	interaction_prompt.hide()
	
	await get_tree().process_frame
	#apply_spawn_if_needed()
	
	player_ready.emit()
	
func _process(delta):
	pass
	#update_targeting_visual()
	
	var item_data = Hotbar.get_selected_item_data()
	
	if item_data is DecorData:
		if not build_mode or item_data.id != current_decor_id:
			if DecorSystem.initialized == true:
				DecorSystem.initialize_build_mode(item_data)
				build_mode = true
				current_decor_id = item_data.id
	else:
		if build_mode:
			DecorSystem.cancel_build_mode()
			build_mode = false
			current_decor_id = ""
	
func setup(interaction_system_ref: InteractionSystem, targeting_system_ref: TargetingSystem) -> void:
	interaction_system = interaction_system_ref
	targeting_system = targeting_system_ref
	initialized = true
	
func update_targeting_visual():
	pass
	
func _physics_process(delta):
	if just_spawned:
		just_spawned = false
		return
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
	
	if not initialized:
		return
		
	player_global_position = get_global_position()
	targeting_system.update_player_info(player_global_position, facing_direction)
	targeting_system.update_current_targets(get_global_mouse_position())
	
	find_reactive_objects()
		
func _input(event: InputEvent) -> void:
	
	## Temporary for debugging
	if Input.is_action_just_pressed("add_debug_items"):
		DebugSystem._add_items_to_inventory()
		
	if Input.is_action_just_pressed("interact"):
		var request = create_interaction_request(InteractionRequest.InteractionMode.PROXIMITY)
		interaction_system.handle_request(request)
		
	if Input.is_action_just_pressed("use_item"):
		if build_mode:
			if DecorSystem.place_decor():
				build_mode = false
				
		var request = create_interaction_request(InteractionRequest.InteractionMode.TARGETED)
		interaction_system.handle_request(request)
	
	if Input.is_action_just_pressed("right_click"):
		if not build_mode:
			return
		DecorSystem.switch_variant()
		
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
		
func create_interaction_request(interaction_mode) -> InteractionRequest:
	var request = InteractionRequest.new()
	
	request.actor = self
	request.interaction_mode = interaction_mode
	request.mouse_pos = get_global_mouse_position()
	
	var selected_item = Hotbar.get_selected_item()
	
	if selected_item != null:
		selected_item = selected_item.item_data
		
	request.selected_item_data = selected_item
	
	return request
	
func lock_scroll():
		scroll_locked = true
		await get_tree().create_timer(0.03).timeout
		scroll_locked = false
	
func _on_interaction_area_area_entered(area: Area2D) -> void:
	
	var object = area.get_parent()
	
	if object.has_method("interact"):
		targeting_system.register_interactable(object)
		
	if object != null and object is WorldItem:
		object.start_magnet(self)
		
	VisibilitySystem.register_object(object)
	
func _on_interaction_area_area_exited(area: Area2D) -> void:
	
	var object = area.get_parent()
	
	if object.has_method("interact"):
		targeting_system.unregister_interactable(object)
		
	VisibilitySystem.unregister_object(object)
	
func update_player_tile_coords():

	var local_pos = tilemap.to_local(global_position)
	player_tile_coords = tilemap.local_to_map(local_pos)
	
func find_reactive_objects():
	var current_tile = player_tile_coords
	var objects = GridManager.get_grid_objects(current_tile)
	
	var new_reactive := {}
	
	for obj in objects:
		if not is_instance_valid(obj):
			continue
			
		if obj.has_method("react"):
			
			var dist = global_position.distance_to(obj.global_position)
			
			if dist < 12:
				new_reactive[obj] = true
				
				if not reactive_objects.has(obj):
					obj.react()
	reactive_objects = new_reactive
	
func get_save_data() -> Dictionary:
	return{
		"position": {
			"x": global_position.x,
			"y": global_position.y
			}
	}
	
func load_from_data(data: Dictionary):
	var pos = data.get("position", {"x": 0, "y": 0})
	
	global_position = Vector2(pos["x"], pos["y"])


func _on_animated_sprite_2d_frame_changed() -> void:
	var walk_anim = [
		"walk_down",
		"walk_up",
		"walk_left",
		"walk_right"
	]

	if not sprite.animation in walk_anim: 
		return
		
	if sprite.frame == 0 or sprite.frame == 2:
		SoundManager.play("walk_grass")
		
#func apply_spawn_if_needed():
	#
	#scene_controller.apply_spawn(self)
