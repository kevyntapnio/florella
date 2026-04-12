extends Node

var current_occluded: Dictionary = {}

func register_object(object):
	
	if not object in current_occluded:
		current_occluded[object] = true
		
		if object.has_method("set_occlusion"):
			object.set_occlusion()
		else:
			push_warning("VisibilitySystemERROR: Object does not have occlusion method")
	
func unregister_object(object):
	if object in current_occluded:
		
		if object.has_method("remove_occlusion"):
			object.remove_occlusion()
		else:
			push_warning("VisibilitySystemERROR: Object does not have occlusion method")
			
		current_occluded.erase(object)
