extends GridObject
class_name ShippingBin

@export var selling_system: Node2D

const INTERACT_PRIORITY = 10

func get_interaction_score(context) -> int:
	return INTERACT_PRIORITY
	
func interact(request: InteractionRequest) -> bool:
	if selling_system == null:
		push_error("ShippingBin ERROR: selling_system not assigned in Editor!")
		return true
		
	selling_system.initialize()
	
	return true
	
func can_accept_item(item_data: ItemData) -> bool:
	return true
	
func is_currently_interactable() -> bool:
	return true
