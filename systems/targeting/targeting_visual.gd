extends Node

var current_target = null
var is_current_valid = false

func update_target(new_target, valid):
		
	if new_target == current_target and valid == is_current_valid:
		return
			
	if current_target and is_instance_valid(current_target):
		if current_target.has_method("set_targeted"):
			current_target.set_targeted(false)
	
	if valid:
		if new_target and new_target.has_method("set_targeted"):
			new_target.set_targeted(true)
		
	current_target = new_target
	is_current_valid = valid
