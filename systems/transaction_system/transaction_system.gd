extends Node

func perform_transaction(cart_items, total_price) -> bool:
	if not is_transaction_valid(cart_items, total_price):
		return false 
		
	for item in cart_items:
		InventorySystem.add_stack(item)
	
	PlayerGlobalStats.remove_from_wallet(total_price)
	
	return true

func is_transaction_valid(cart_items, total_price) -> bool:
	var current_gold = PlayerGlobalStats.get_current_gold()
	
	if current_gold < total_price:
		print("not enough money!")
		return false
		
	return true
