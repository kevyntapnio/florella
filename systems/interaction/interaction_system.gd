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
	var interactable = get_closest_interactable()

	if interactable != null:
		interactable.interact(selected_item, player_tile)
		return
	
	var target_tile = TargetingSystem.current_target_coords
	var target_object = GridManager.get_grid_objects(target_tile)
	
	var context = InteractionContext.new(player_tile, target_tile)
	
	
	if target_object != null:
		target_object.interact(selected_item, context)
		return
				
