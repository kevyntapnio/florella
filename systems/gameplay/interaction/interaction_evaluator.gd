class_name InteractionEvaluator
extends RefCounted

func evaluate_interaction_request(
	target: InteractionTarget, request: InteractionRequest
	) -> bool:
	
	if target == null:
		return false 
		
	var target_object = target.target_object
	
	if target_object == null:
		return false
	
	if not is_currently_interactable(target_object):
		return false
	
	if not can_accept_item(target_object, request):
		return false
	
	## Check range only for tool/item interactions
	if request.interaction_mode == InteractionRequest.InteractionMode.TARGETED:
		if not is_in_range(target, request):
			return false
	
	return true
		
func can_accept_item(target_object: Node2D, request: InteractionRequest) -> bool:

	var item_data = request.selected_item_data
	## ---- item knows if "null" can be handled, so null check not provided here
	if not target_object.has_method("can_accept_item"):
		return false
		
	return target_object.can_accept_item(item_data)
	
func is_currently_interactable(target_object: Node2D) -> bool:
	
	if not target_object.has_method("is_currently_interactable"):
		return false 
	return target_object.is_currently_interactable()
	
func is_in_range(target: InteractionTarget, request: InteractionRequest) -> bool:
	assert(request.actor != null)
	
	var item_data = request.selected_item_data
		
	if not item_data is UsableItem:
		return false
	
	## NOTE: Centralize normalization behavior in the future
	
	var player_pos = request.actor.global_position
	var interaction_range = item_data.interaction_range
	var interaction_zone = target.interaction_zone
	
	var normalized_pos = WorldSpace.world_to_interaction_cell(player_pos)
		
	var normalized_range = int(interaction_range * (
		WorldSpace.LOGIC_GRID_SIZE / WorldSpace.INTERACTION_CELL_SIZE)
		)
	
	for cell in interaction_zone:
		var dx = abs(normalized_pos.x - cell.x)
		var dy = abs(normalized_pos.y - cell.y)
		
		var distance = max(dx, dy)
		
		## return true as soon as 1 valid tile is found
		if distance <= normalized_range:
			return true
			
	return false
