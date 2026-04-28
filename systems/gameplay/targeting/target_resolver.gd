class_name TargetResolver
extends RefCounted

func resolve_proximity_target(
	target_candidates: Array, 
	player_position: Vector2, 
	facing_direction: Vector2i
	) -> Node2D:
	
	if target_candidates.is_empty():
		return
		
	if target_candidates.size() == 1:
		return target_candidates[0]
		
	var player_pos = player_position
	var facing_dir = Vector2(facing_direction).normalized()
	
	var best_front_obj = null
	var best_front_distance = INF
	
	var fallback_object = null
	var best_score = -1
	
	for obj in target_candidates:
		if not is_instance_valid(obj):
			continue
			
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
				best_score = score
				fallback_object = obj
				
	if best_front_obj != null:
		return best_front_obj
		
	return fallback_object
	
func resolve_targeted_target(target_candidates) -> Node2D:
	
	if target_candidates.is_empty():
		return
		
	if target_candidates.size() == 1:
		return target_candidates[0]
		
	var best_score = -1
	var best_object = null
	
	for obj in target_candidates:
		if not is_instance_valid(obj):
			continue
			
		if obj.has_method("get_interaction_score"):
			var score = obj.get_interaction_score(null)
			
			if score > best_score:
				best_object = obj
				best_score = score
		
	return best_object
	
