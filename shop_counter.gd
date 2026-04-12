extends GridObject
class_name ShopCounter

@export var shop_info: ShopInfo

func interact(item, context) -> bool:
	if shop_info == null:
		push_error("ShopCounter ERROR: shop_info not assigned Editor")
		return false
		
	open_shop_menu()
	return true
	
func is_shop_open():
	
	var hour = TimeManager.current_hour
	var minute = TimeManager.current_minute
	
	var current_time = (hour * 60) + minute
	
	return current_time >= shop_info.opening_time and current_time <= shop_info.closing_time

func open_shop_menu():
	if is_shop_open():
		## open shop ui
		print("shop is open")
	else:
		print("shop is closed")
		
