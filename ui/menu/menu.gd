extends CanvasLayer
class_name MenuBase

var is_open:= false 

func open():
	if is_open:
		return
		
	is_open = true
	visible = true
	TimeManager.pause_time(self)
	
func close():
	if not is_open:
		return
	
	_on_pre_close()
		
	is_open = false
	visible = false
	TimeManager.resume_time(self)
	
	_on_post_close()

func _input(event: InputEvent) -> void:
	if not is_open: 
		return
		
	if event.is_action_pressed("ui_cancel"):
		close()
		get_viewport().set_input_as_handled()

func _on_pre_close():
	
	if SlotInteraction.held_stack != null:
		SlotInteraction.cancel_held()

func _on_post_close():
	pass
