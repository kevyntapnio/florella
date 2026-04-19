extends TextureButton
class_name ButtonUI

@export var hover_modulate:= Color(1.1, 1.1, 1.1)
@export var normal_modulate:= Color(1.0, 1.0, 1.0)
@export var pressed_modulate:= Color(0.95, 0.9, 0.9)
@export var inactive_modulate:= Color(0.5, 0.5, 0.5)

func _ready():
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	button_down.connect(_on_button_down)
	
func _on_mouse_entered():
	modulate = hover_modulate
	SoundManager.play("ui_hover")
	
func _on_mouse_exited():
	modulate = normal_modulate

func _on_button_down():
	modulate = pressed_modulate
	scale = Vector2(0.97, 0.97)
	
func _on_button_up():
	scale = Vector2(1.0, 1.0)
	modulate = normal_modulate
	
	
