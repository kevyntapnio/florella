extends Node
class_name Shop

var shop_system
var shop_ui: Control
var shop_entries: Array[Resource] = []

func initialize(shop_items, ui):
	shop_system = get_parent()
	shop_ui = ui
	shop_entries = shop_items
	
	shop_ui.initialize(shop_entries)
	
func handle_left_click(index):
		
	if shop_entries.is_empty():
		push_error("ShopClass ERROR: no shop_entries found")
		return

	var item_in_slot = shop_entries[index]
	var price = get_adjusted_price(item_in_slot.get_price())
	
	var stack = ItemStack.new()
	stack.item_data = item_in_slot.item
	stack.quantity = 1
	stack.unit_price = price
		
	shop_system.handle_current_stack(stack)

func get_adjusted_price(price):
	#check for discount day, adjust pricing
	#temporary. added only to verify flow 
	var adjusted_price = price
	return adjusted_price
	
func confirm_purchase():
	shop_system.handle_purchase_confirmation()
