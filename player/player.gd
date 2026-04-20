extends CharacterBody2D

const SPEED = 150
var facing_direction = Vector2i(0, 1)

@onready var interaction_area = $InteractionArea

@export var tilemap: TileMapLayer
@export var tile_highlight: Node2D

@onready var sprite = $AnimatedSprite2D
@onready var interaction_prompt = $InteractionPrompt
@onready var tile_detector = $TileDetector

const INVALID_COORD = Vector2i(-1, -1)

var focused_interactable = null
var player_tile_coords: Vector2i
var player_global_position
var scroll_locked
var reactive_objects: Dictionary = {}

func _ready() -> void:
	interaction_prompt.hide()
	
func _process(delta):
	update_targeting_visual()
	
func update_targeting_visual():

	var item_data = Hotbar.get_selected_item_data()
	
	var usable_item = null
	if item_data is UsableItem:
		usable_item = item_data
	
	if usable_item != null:
		
		var player_tile = player_tile_coords
		var target_tile = TargetingSystem.current_target_coords
		
		var objects = GridManager.get_grid_objects(target_tile)
		
		var context = InteractionContext.new(player_tile, target_tile)
		context.tool = usable_item
		
		var valid = false
		
		for obj in objects:
			
			if obj.has_method("get_interaction_score") and obj.has_method("can_accept_item"):
				var score = obj.get_interaction_score(context)
				
				if score > 0 and obj.can_accept_item(usable_item, context):
					if usable_item.is_in_range(target_tile, context):
						valid = true
						break
					
		tile_highlight.show_highlight()
		tile_highlight.highlight_tile(target_tile, valid)
	
	else:
		tile_highlight.hide()
		
	var valid = InteractionSystem.has_valid_interaction()
	if valid:
		interaction_prompt.show()
	else:
		interaction_prompt.hide()
		
	TargetingVisual.update_target(InteractionSystem.focused_interactable, valid)
	
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
	
	TargetingSystem.player_tile_coords = player_tile_coords
	TargetingSystem.facing_direction = facing_direction
	TargetingSystem.player_global_position = global_position

	TargetingSystem.update_current_target()
	
	find_reactive_objects()
		
func _input(event: InputEvent) -> void:
	
	if Input.is_action_just_pressed("interact"):
		InteractionSystem.handle_interact_proximity(null)
		
	if Input.is_action_just_pressed("use_item"):
		var item = Hotbar.get_selected_item()
		
		if item == null:
			return
		var item_data = ItemDatabase.get_item(item.item_data.id)
		
		if not (item_data is UsableItem):
			return
			
		InteractionSystem.handle_interact_grid(item)
		
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
		
func lock_scroll():
		scroll_locked = true
		await get_tree().create_timer(0.03).timeout
		scroll_locked = false
	
func _on_interaction_area_area_entered(area: Area2D) -> void:
	
	var object = area.get_parent()
	
	if object.has_method("interact"):
		InteractionSystem.register_interactable(object)
		
	if object != null and object is WorldItem:
		object.start_magnet(self)
		
	VisibilitySystem.register_object(object)
	
func _on_interaction_area_area_exited(area: Area2D) -> void:
	
	var object = area.get_parent()
	
	if object.has_method("interact"):
		InteractionSystem.unregister_interactable(object)
		
	VisibilitySystem.unregister_object(object)
	
func update_player_tile_coords():

	var local_pos = tilemap.to_local(global_position)
	player_tile_coords = tilemap.local_to_map(local_pos)
	
func find_reactive_objects():
	var current_tile = player_tile_coords
	var objects = GridManager.get_grid_objects(current_tile)
	
	var new_reactive := {}
	
	for obj in objects:
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
