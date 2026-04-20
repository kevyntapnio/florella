extends Node2D

@export var sell_menu_ui: CanvasLayer
var sell_container: SlotContainer

func initialize():
	create_sell_container()
	sell_menu_ui.open()
	
func create_sell_container():
	sell_container = SellContainer.new()
	
	var shipping_bin_ui = sell_menu_ui.shipping_bin_ui
	
	sell_container.container_ui = shipping_bin_ui
	shipping_bin_ui.initialize(sell_container)
	
	add_child(sell_container)

func handle_sell_request():
	var sell_items = sell_container.get_sell_items()
	var price = sell_container.get_total_price()

	## in the future, sell_price multipliers may be calculated here
	## example: bouquet scoring
	
	if TransactionSystem.perform_sell_transaction(sell_items, price):
		SoundManager.play("coin")
		sell_container.reset_session()
		
