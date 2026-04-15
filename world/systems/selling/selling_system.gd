extends Node2D

@export var sell_menu_ui: CanvasLayer
var cart: Cart

func initialize():
	var inventory_copy = InventorySystem.get_inventory()
	
	#sell_menu_ui.initialize(inventory_copy)
	var cart = Cart.new()
	add_child(cart)
	print(cart)
