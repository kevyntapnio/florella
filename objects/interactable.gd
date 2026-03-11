extends Area2D

class_name Interactable

func interact():
	var parent = get_parent()
	
	if parent.has_method("on_interact"):
		parent.on_interact()
	
func on_focus_entered():
	print("focus entered")
	
func on_focus_exited():
	print("focus exited")
	
