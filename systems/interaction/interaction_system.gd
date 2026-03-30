extends Node2D

var nearby_interactables: Array = []
var focused_interactable = null

func _process(delta: float) -> void:
	update_focused_interactable()
	
func register_interactable(interactable):
	nearby_interactables.append(interactable)

func unregister_interactable(interactable):
	nearby_interactables.erase(interactable)
	
func get_closest_interactable():
	
	if nearby_interactables.is_empty():
		return null
	if TargetingSystem.player_global_position == null:
		return null
		
	var closest_object = null
	var smallest_distance = INF
	
	for interactable in nearby_interactables:
		var distance = TargetingSystem.player_global_position.distance_to(interactable.global_position)
		
		
		if distance < smallest_distance:
			smallest_distance = distance
			closest_object = interactable
	
	return closest_object
	
func update_focused_interactable():
	
	var closest_interactable = get_closest_interactable()
	
	if closest_interactable != focused_interactable:
		
		if focused_interactable:
			focused_interactable.on_focus_exited()
		
		focused_interactable = closest_interactable
		
		if focused_interactable:
			focused_interactable.on_focus_entered()
			
func handle_interact(selected_item):
	var player_tile = TargetingSystem.player_tile_coords
	var target_tile = TargetingSystem.current_target_coords
	
	var grid_objects = GridManager.get_grid_objects(target_tile)
	
	var context = InteractionContext.new(player_tile, target_tile)
	
	var best_object = null
	var best_score = -1
	
	for obj in grid_objects:
		if obj.has_method("get_interaction_score") and obj.has_method("interact"):
			var score = obj.get_interaction_score(context)
			
			if score > best_score:
				best_score = score
				best_object = obj
		
	if best_object != null:
		best_object.interact(selected_item, context)
