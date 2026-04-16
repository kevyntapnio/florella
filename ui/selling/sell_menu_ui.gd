extends CanvasLayer

@export var selling_bin_ui: Control
@export var inventory_copy: Control
@export var confirm_button: Button
@export var selling_system: Node2D

var is_open = false

func _ready():
	layer = 11
	visible = false
	is_open = false

func open_sell_menu(): 
	TimeManager.pause_time(self)
	inventory_copy.initialize()
	inventory_copy.open_menu()
	visible = true
	is_open = true 

func close_sell_menu():
	TimeManager.resume_time(self)
	inventory_copy.close_menu()
	visible = false
	is_open = false
	
func _input(event: InputEvent) -> void:
	if not is_open:
		return
		
	if event.is_action_pressed("ui_cancel"):
		close_sell_menu()
		get_viewport().set_input_as_handled()
		
func click_received(slot_index):
	selling_system.handle_left_click(slot_index)
