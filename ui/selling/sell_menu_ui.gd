extends MenuBase
class_name SellMenuUI

@export var shipping_bin_ui: Control
@export var selling_system: Node2D


func _ready():
	layer = 11
	visible = false
	is_open = false

func _on_pre_close():
	super._on_pre_close()
	var container = shipping_bin_ui.container
	
	if not container.is_empty():
		container.handle_unsold_items()
	
func _on_button_pressed() -> void:
	selling_system.handle_sell_request()
	
