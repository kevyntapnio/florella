extends Node2D

@export var sell_menu_ui: CanvasLayer

func initialize():
	
	sell_menu_ui.open_sell_menu()
	
	var bin = SellingBin.new()
	bin.selling_bin_ui = sell_menu_ui.selling_bin_ui
	add_child(bin)
