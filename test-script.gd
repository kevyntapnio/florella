extends Node


var inventory: Array = []

func add_item(item_id, amount):
	
	## Check if item can be stacked
	
	for i in range(inventory.size()):
		if inventory[i] != null and inventory[i]["id"] == item_id:
				inventory[i]["quantity"] += amount
				return
	
	## Check for first empty slot
	
	for i in range(inventory.size()):
		if inventory[i] == null:
			inventory[i] = {"id": item_id, "quantity": amount}
			return
	
	## Both checks done but return hasn't been called yet, so inventory is full
	
	print("Inventory is full")
	
func get_item(index):
	
	if index < 0 or index >= inventory.size():
		return null
		
	return inventory[index]
	
func remove_item(item_id, amount):
	
	var remaining_to_remove = amount
	
	for i in range(inventory.size()):
		var item = inventory[i]
		
		if item == null:
				continue
				
		if item["id"] == item_id:
			if item["quantity"] > remaining_to_remove:
				item["quantity"] -= remaining_to_remove
				remaining_to_remove = 0
				break
			else:
				remaining_to_remove -= item["quantity"]
				inventory[i] = null
				
		if remaining_to_remove == 0:
			break
	
	# Signal for UI sync
	inventory_changed.emit()
	return amount - remaining_to_remove
	
