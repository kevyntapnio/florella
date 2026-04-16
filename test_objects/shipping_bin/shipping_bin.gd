extends GridObject
class_name ShippingBin

@export var selling_system: Node2D

const INTERACT_PRIORITY = 10

func get_interaction_score(context):
	return INTERACT_PRIORITY
	
func interact(item, context):
	if selling_system == null:
		push_error("ShippingBin ERROR: selling_system not assigned in Editor!")
		
	print("Shipping bin interaction triggered")
	#selling_system.initialize()
	
