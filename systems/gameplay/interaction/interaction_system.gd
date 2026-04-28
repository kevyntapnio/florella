class_name InteractionSystem
extends Node

var targeting_system: TargetingSystem
var interaction_evaluator: InteractionEvaluator

func setup(targeting_system_ref: TargetingSystem) -> void:
	targeting_system = targeting_system_ref
	interaction_evaluator = InteractionEvaluator.new()
		
func handle_request(request: InteractionRequest) -> void:
	assert(interaction_evaluator != null)
	
	var interaction_mode = request.interaction_mode
	var target = get_current_target(interaction_mode)
	var is_interaction_valid = interaction_evaluator.evaluate_interaction_request(target, request)
		
	if is_interaction_valid:
		if await execute(target, request):
			handle_successful_interaction(target, request)
		
func execute(target: InteractionTarget, request: InteractionRequest) -> bool:
	
	if target == null:
		return false
		
	var target_object = target.target_object
	
	if target_object == null:
		return false
		
	## target SHOULD have this method from filtering, but added just in case
	if target_object.has_method("interact"):
		return await target_object.interact(request)
		
	return false
	
func get_current_target(interaction_mode: InteractionRequest.InteractionMode) -> InteractionTarget:
	assert(targeting_system != null)
	
	if interaction_mode == null:
		return null
	
	if interaction_mode == InteractionRequest.InteractionMode.PROXIMITY:
		return targeting_system.get_current_proximity_target()
		
	if interaction_mode == InteractionRequest.InteractionMode.TARGETED:
		return targeting_system.get_current_targeted_target()
		
	return null
	
func handle_successful_interaction(target: InteractionTarget, request: InteractionRequest):
	
	var item_data = request.selected_item_data
	
	if item_data != null and item_data.is_consumable:
		InventorySystem.remove_item(item_data.id, 1)
