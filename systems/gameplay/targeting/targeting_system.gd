class_name TargetingSystem
extends Node

### TODO: Remove these after refactor cleanup 
var tilemap: TileMapLayer
var player_tile_coords
var current_target_coords
var current_target_cell
### ---------- ###

var resolver: TargetResolver
var interaction_target_builder: InteractionTargetBuilder
var initialized := false

var facing_direction
var player_global_position

var current_proximity_candidates: Array = []
var current_proximity_target: InteractionTarget

var current_targeted_target: InteractionTarget

func set_tilemap(map: TileMapLayer):
	tilemap = map
	
	initialized = true
	
func setup():
	## in the future, this function will receive resolver instead of creating it
	resolver = TargetResolver.new()
	interaction_target_builder = InteractionTargetBuilder.new()
	
func update_player_info(player_pos: Vector2, player_facing_dir: Vector2i) -> void:
	if player_global_position != player_pos:
		player_global_position = player_pos
		
	if facing_direction != player_facing_dir:
		facing_direction = player_facing_dir
	
func register_interactable(object) -> void:
	if not current_proximity_candidates.has(object):
		current_proximity_candidates.append(object)

func unregister_interactable(object) -> void:
	if current_proximity_candidates.has(object):
		current_proximity_candidates.erase(object)
		
func update_current_targets(mouse_pos: Vector2) -> void:
	var proximity_target_object = resolve_proximity_target()
	var new_proximity_target = interaction_target_builder.build(proximity_target_object)
	
	if is_target_changed(current_proximity_target, new_proximity_target):
		current_proximity_target = new_proximity_target
		
	var mouse_target_object = resolve_mouse_target(mouse_pos)
	var new_mouse_target = interaction_target_builder.build(mouse_target_object)
	
	if is_target_changed(current_targeted_target, new_mouse_target):
		current_targeted_target = new_mouse_target
	
func resolve_proximity_target() -> Node2D:
	assert(resolver != null)
	
	var proximity_target_object = resolver.resolve_proximity_target(
		current_proximity_candidates, 
		player_global_position, 
		facing_direction
		)
	
	return proximity_target_object
	
func resolve_mouse_target(mouse_pos: Vector2) -> Node2D:
		
	var target_mouse_candidates = get_mouse_target_candidates(mouse_pos)
	return resolver.resolve_targeted_target(target_mouse_candidates)
	
func get_mouse_target_candidates(mouse_pos: Vector2) -> Array[Node2D]:
	var grid_objects = GridManager.get_objects_at_world_pos(mouse_pos)
	var spatial_objects = SpatialLookup.get_objects_at_world_pos(mouse_pos)
	
	var target_candidates: Array[Node2D] = []
	
	target_candidates.append_array(grid_objects)
	target_candidates.append_array(spatial_objects)
	
	var interactable_candidates = filter_target_candidates(target_candidates)
	
	return interactable_candidates
	
func filter_target_candidates(target_candidates: Array[Node2D]) -> Array[Node2D]:
	
	var interactable_candidates: Array[Node2D] = []
	
	for object in target_candidates:
		if not is_interactable(object):
			continue
		interactable_candidates.append(object)
			
	return interactable_candidates
	
func is_interactable(object) -> bool:
	return object.has_method("interact")
	
func is_target_changed(current: InteractionTarget, new: InteractionTarget) -> bool:
	
	if current == null and new == null:
		return false 
	
	if current == null or new == null:
		return true
		
	return current.target_object != new.target_object
	
func get_current_proximity_target() -> InteractionTarget:
	return current_proximity_target
	
func get_current_targeted_target() -> InteractionTarget:
	return current_targeted_target
