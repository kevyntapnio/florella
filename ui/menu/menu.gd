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
		
	is_open = false
	visible = false
	TimeManager.resume_time(self)
