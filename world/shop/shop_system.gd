extends Node

@export var shop_ui: CanvasLayer

func initialize_shop(shop_info):
	var shop_data = shop_info.shop_data
	var shop_entries = shop_data.shop_entries
	
	if shop_ui == null:
		print("ShopSystem ERROR: shop_ui not assigned in Editor")
		return
	
	shop_ui.initialize(shop_entries)
	
