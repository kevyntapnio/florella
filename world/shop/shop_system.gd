extends Node

@export var shop_menu_ui: CanvasLayer
var shop_ui
var cart_ui

var cart: Cart
var shop: Shop

func initialize_shop(shop_info):
	var shop_data = shop_info.shop_data
	var shop_entries = shop_data.shop_entries
	
	if shop_menu_ui == null:
		print("ShopSystem ERROR: shop_menu_ui not assigned in Editor")
		return
		
	shop_ui = shop_menu_ui.shop_ui
	cart_ui = shop_menu_ui.cart_ui
	
	create_shop()
	shop.initialize(shop_entries, shop_ui)
	create_cart()
	
	shop_menu_ui.open_shop_menu()

func create_shop():
	shop = Shop.new()
	shop_ui.shop = shop
	add_child(shop)
	
func create_cart():
	cart = Cart.new()
	cart.cart_ui = cart_ui
	add_child(cart)

func clear_shop_menu():
	shop_menu_ui.close_shop_menu()
	cart.queue_free()
	shop.queue_free()
	
func handle_current_stack(stack):
	cart.add_stack(stack)
	
func handle_purchase_confirmation():
	var cart_items = cart.get_cart_items()
	var total_price = cart.total_price
	
	if TransactionSystem.perform_transaction(cart_items, total_price):
		SoundManager.play("coin")
		clear_shop_menu()
	else:
		print("Not enough money")

	
