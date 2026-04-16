extends Node2D

@export var sell_menu_ui: CanvasLayer
var sell_container: SlotContainer

func initialize():
	create_sell_container()
	sell_menu_ui.open()
	
func create_sell_container():
	sell_container = SellContainer.new()
	sell_container.container_ui = sell_menu_ui.shipping_bin_ui
	
