extends GridObject
class_name ShippingBin

@export var selling_system: Node2D

const INTERACT_PRIORITY = 10

func get_interaction_score(context):
	return INTERACT_PRIORITY
	
func interact(item, context):
	print("Shipping bin interaction triggered")
	selling_system.initialize()
	
