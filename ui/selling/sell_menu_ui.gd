extends MenuBase

@export var shipping_bin_ui: Control
@export var inventory_copy: Control
@export var confirm_button: Button
@export var selling_system: Node2D


func _ready():
	layer = 11
	visible = false
	is_open = false

func open_sell_menu(): 
	open()
	visible = true
	is_open = true 

func close_sell_menu():
	TimeManager.resume_time(self)
	visible = false
	is_open = false
	
