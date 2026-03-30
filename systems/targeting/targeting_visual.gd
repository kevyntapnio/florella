extends Node


var current_target = null

func update_target(new_target):
	
	if current_target and current_target != new_target:
		if is_instance_valid(current_target) and current_target.has_method("set_targeted"):
			current_target.set_targeted(false)
			
	if new_target and new_target.has_method("set_targeted"):
		new_target.set_targeted(true)
		
	current_target = new_target
