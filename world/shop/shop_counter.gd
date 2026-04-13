extends GridObject
class_name ShopCounter

@export var shop_system: Node
@export var shop_info: ShopInfo

func interact(item, context) -> bool:

	if shop_info == null:
		push_error("ShopCounter ERROR: shop_info not assigned Editor")
		return false
		
	open_shop_menu()
	return true
	
func is_shop_open():

	var current_time = (TimeManager.current_hour * 60) + TimeManager.current_minute
	
	return current_time >= shop_info.opening_time and current_time < shop_info.closing_time

func open_shop_menu():
	#var npc = shop_info.shop_npc
	
	#if npc.is_in_shop():
		##trigger dialogue
	#else:
		#pass
		
	if is_shop_open():
		## open shop_menu
		if shop_system == null:
			push_error("ShopCounter ERROR: ShopSystem not assigned in Editor")
		
		shop_system.initialize_shop(shop_info)
	else:
		print("shop is closed")
		
