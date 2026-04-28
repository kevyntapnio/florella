class_name InteractionTargetBuilder
extends RefCounted

func build(target: Node2D) -> InteractionTarget:
	if target == null:
		return null
	
	var target_object = target
	var interaction_zone: Array = []
	var interaction_score: float = 0
	
	if target.has_method("get_interaction_zone"):
		interaction_zone = target.get_interaction_zone()
		
	if target.has_method("get_interaction_score"):
		interaction_score = target.get_interaction_score(null)
		
	var interaction_target = InteractionTarget.new(
		target_object,
		interaction_zone, 
		interaction_score)
	
	return interaction_target
	
