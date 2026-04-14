extends Node

@export var shop_ui: CanvasLayer
var cart: Cart
var shop: Shop

func initialize_shop(shop_info):
	var shop_data = shop_info.shop_data
	var shop_entries = shop_data.shop_entries
	
	if shop_ui == null:
		print("ShopSystem ERROR: shop_ui not assigned in Editor")
		return
	
	create_shop()
	shop_ui.shop = shop
	shop.initialize(shop_entries, shop_ui)
	create_cart()
	
func create_shop():
	shop = Shop.new()
	add_child(shop)
	
func create_cart():
	cart = Cart.new()
	add_child(cart)

func clear_shop_menu():
	shop_ui.close_menu()
	cart.queue_free()
	shop.queue_free()
	
func handle_current_stack(stack, price):
	cart.add_stack(stack, price)
	
func handle_purchase_confirmation():
	var cart_items = cart.get_cart_items()
	var total_price = cart.total_price
	
	if TransactionSystem.perform_transaction(cart_items, total_price):
		clear_shop_menu()
	else:
		print("Not enough money")

	
