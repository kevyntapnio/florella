class_name PlacementExecutor
extends RefCounted

var placement_validator: PlacementValidator

func setup(placement_validator_ref: PlacementValidator) -> void:
	self.placement_validator = placement_validator_ref
	
func handle_placement(context: PlacementContext, request: PlacementRequest) -> bool:
	
	var result = placement_validator.evaluate_placement(context)
	
	if not result.valid:
		return false
	
	var decor_instance = request.decor_instance
	
	decor_instance.surface_object = result.surface_object
	
	decor_instance.set_placed_mode(request.current_variant, result)
	decor_instance.position.y = result.surface_object.position.y + 1.0

	return true
