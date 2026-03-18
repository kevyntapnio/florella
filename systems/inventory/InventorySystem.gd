extends Node

var inventory: Array[Dictionary] = []

func add_item(item_id, amount):

	var found = false

	for item in inventory:
		if item["id"] == item_id:
			item["quantity"] += amount
			found = true
			break
		
	if found == false:
		inventory.append({"id": item_id, "quantity": amount}) 
		
func has_item(item_id, amount) -> bool:
	
	for item in inventory:
		if item["id"] == item_id:
			if item["quantity"] >= amount:
				return true
			else:
				return false
	return false
	
func remove_item(item_id, amount):
	
	var item_removed = 0
	
	for item in inventory:
		
		if item["id"] == item_id:
			if item["quantity"] >= amount:
				item["quantity"] -= amount
				item_removed = amount
			else:
				item_removed = item["quantity"]
				inventory.erase(item)
				return item_removed
			
			if item["quantity"] == 0:
				inventory.erase(item)
				
			return item_removed
			
	return item_removed
	
