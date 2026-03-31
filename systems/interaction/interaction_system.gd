extends Node2D

var nearby_interactables: Array = []
var focused_interactable = null

func _process(delta: float) -> void:
	update_focused_interactable()
	
func register_interactable(interactable):
	nearby_interactables.append(interactable)
	
func unregister_interactable(interactable):
	nearby_interactables.erase(interactable)
	
func get_best_interactable():
	
	if nearby_interactables.is_empty():
		return null
		
	var player_pos = TargetingSystem.player_global_position
	var facing_dir = Vector2(TargetingSystem.facing_direction).normalized()
	
	var best_front_obj = null
	var best_front_distance = INF
	
	var fallback_object = null
	var best_score = INF
	
	for obj in nearby_interactables:
		var to_obj = obj.global_position - player_pos
		var distance = to_obj.length()
		var dir = to_obj.normalized()
		
		var dot = facing_dir.dot(dir)
		
		var close_range = 16
		if distance < close_range: 
			if distance < best_front_distance:
				best_front_distance = distance
				best_front_obj = obj
			continue
		
		## ---- lower number, wider cone ---- ##
		if dot > 0.2:
			if distance < best_front_distance:
				best_front_distance = distance
				best_front_obj = obj
		
		if obj.has_method("get_interaction_score"):
			var score = obj.get_interaction_score(null)
			
			score -= distance * 0.1
			
			if score > best_score:
				best_score = best_score
				fallback_object = obj
				
	if best_front_obj != null:
		return best_front_obj
		
	return fallback_object
				
	
func update_focused_interactable():
	focused_interactable = get_best_interactable()
			
func handle_interact_grid(selected_item):
	
	if selected_item == null:
		return
		
	var item_data = ItemDatabase.get_item(selected_item.item_data.id)
	
	if not (item_data is UsableItem):
		return
		
	var player_tile = TargetingSystem.player_tile_coords
	var target_tile = TargetingSystem.current_target_coords
	
	var grid_objects = GridManager.get_grid_objects(target_tile)
	
	var usable_item = null
	
	if item_data is UsableItem:
		usable_item = item_data
			
	var context = InteractionContext.new(player_tile, target_tile)
	context.tool = usable_item
	
	var best_object = null
	var best_score = -1
	
	for obj in grid_objects:
		
		if not obj.has_method("can_accept_item"):
			continue
			
		if not obj.can_accept_item(usable_item, context):
			continue
			
		var score = obj.get_interaction_score(context)
			
		if score > best_score:
			best_score = score
			best_object = obj
		
	if best_object != null:
		best_object.interact(usable_item, context)
		
func handle_interact_proximity(_selected_item):
	
	if focused_interactable == null:
		return
		
	var player_tile = TargetingSystem.player_tile_coords
	var target_tile = focused_interactable.grid_position
	
	var context = InteractionContext.new(player_tile, target_tile)
	context.tool = null
	
	if focused_interactable.has_method("can_accept_item"):
		if not focused_interactable.can_accept_item(null, context):
			return
			
	focused_interactable.interact(null, context)
