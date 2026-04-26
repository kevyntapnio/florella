extends Node

var current_target = null
var is_current_valid = false

var current_mouse_target = null
var is_mouse_target_valid = false

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
		
func update_mouse_target(new_target, valid):
	
	if new_target == current_mouse_target and valid == is_mouse_target_valid:
		return
	
	if is_instance_valid(current_mouse_target):
		if current_mouse_target.has_method("set_targeted"):
			current_mouse_target.set_targeted(false)
	
	current_mouse_target = new_target
	is_mouse_target_valid = valid
	
	if is_mouse_target_valid and is_instance_valid(current_mouse_target):
		if current_mouse_target.has_method("set_targeted"):
			current_mouse_target.set_targeted(true)
	
