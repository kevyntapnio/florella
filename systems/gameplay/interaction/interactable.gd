extends Node2D

class_name Interactable

func interact(item):
	var parent = get_parent()
	if parent.has_method("on_interact"):
		parent.on_interact(item)
	
func on_focus_entered():
	var parent = get_parent()
	if parent.has_method("on_focus_entered"):
		parent.on_focus_entered()
	
func on_focus_exited():
	var parent = get_parent()
	if parent.has_method("on_focus_exited"):
		parent.on_focus_exited()
		
func get_interaction_action():
	var parent = get_parent()
	
	if parent.has_method("get_interaction_action"):
		return parent.get_interaction_action()
	
	return "Interact"
