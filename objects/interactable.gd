extends Area2D

class_name Interactable

func interact():
	print("Interactable triggered")
	var parent = get_parent()
	
	if parent.has_method("on_interact"):
		parent.on_interact()
	
