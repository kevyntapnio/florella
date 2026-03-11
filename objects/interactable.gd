extends Area2D

class_name Interactable

func interact():
	var parent = get_parent()
	if parent.has_method("on_interact"):
		parent.on_interact()
	
func on_focus_entered():
	var parent = get_parent()
	if parent.has_method("on_focus_entered"):
		parent.on_focus_entered()
	
func on_focus_exited():
	var parent = get_parent()
	if parent.has_method("on_focus_exited"):
		parent.on_focus_exited()
		
