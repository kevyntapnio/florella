extends Node

signal inventory_changed

var inventory = []

func _ready():
	for i in range(30):
		inventory.append(null)
		
func add_item(item_id, amount):
	
	## Check if item can be stacked
	
	for i in range(inventory.size()):
		if inventory[i] != null and inventory[i]["id"] == item_id:
				inventory[i]["quantity"] += amount
				inventory_changed.emit()
				return
	## Check for first empty slot
	
	for i in range(inventory.size()):
		if inventory[i] == null:
			inventory[i] = {"id": item_id, "quantity": amount}
			inventory_changed.emit()
			return
	
	## Both checks done but return hasn't been called yet, so inventory is full
	print("Inventory is full")
		
func has_item(item_id, amount) -> bool:
	
	var total = 0

	for item in inventory:
		if item == null:
			continue
		
		if item["id"] == item_id:
			total += item["quantity"]
		
			if total >= amount:
				return true
	
	return false
	
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
	
## This is for Inventory UI
func get_inventory() -> Array:
	return inventory.duplicate()
	
func get_item(index):
	
	if index < 0 or index >= inventory.size():
		return null
		
	return inventory[index]
