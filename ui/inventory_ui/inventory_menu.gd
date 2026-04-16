extends MenuBase

func _ready():
	layer = 10
	visible = false
	
func toggle():
	if is_open:
		close()
	else:
		open()
		
func _input(event: InputEvent) -> void:
	
	if event.is_action_pressed("ui_cancel"):
		toggle()
		get_viewport().set_input_as_handled()
