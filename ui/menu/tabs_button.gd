extends ButtonUI

## temporary for debugging only
@export var is_active:= false

func _ready() -> void:
	super()
	if not is_active:
		modulate = inactive_modulate
	else:
		modulate = normal_modulate
func _on_mouse_exited():
	super()
	if not is_active:
		modulate = inactive_modulate
	else:
		modulate = normal_modulate
	
func _on_button_up():
	super()
	modulate = inactive_modulate
