extends Node

signal inventory_changed

var inventory = []

func _ready():
	for i in range(30):
		inventory.append(null)
		
func add_item(item_id, amount):
	
	var item_data = ItemDatabase.get_item(item_id)
	
	if item_data == null:
		print("INVALID ITEM", item_id)
		return
		
	var stack = ItemStack.new()
	stack.item_data = item_data
	stack.quantity = amount
	
	add_stack(stack)
	
func add_stack(stack):
	
	for i in range(inventory.size()):
		if inventory[i] == null:
			continue
			
		if inventory[i].item_data == stack.item_data:
			var max_stack = stack.item_data.max_stack
			var space = max_stack - inventory[i].quantity
				
			if space > 0:
				var to_add = min(space, stack.quantity)
			
				inventory[i].quantity += to_add
				inventory_changed.emit()
				
				stack.quantity -= to_add
				if stack.quantity <= 0:
					return stack
			
	for i in range(inventory.size()):
			
		if inventory[i] == null:
			var new_stack = ItemStack.new()
			new_stack.item_data = stack.item_data
			
			var to_add = min(stack.item_data.max_stack, stack.quantity)
			new_stack.quantity = to_add
			
			inventory[i] = new_stack
			inventory_changed.emit()
			
			stack.quantity -= to_add
			
			if stack.quantity <= 0:
				return stack
		
	return stack
	
func add_to_slot(slot_index, stack: ItemStack) -> bool:
	var slot_stack = inventory[slot_index]
	
	var item_in_slot = inventory[slot_index]
	
	if slot_stack == null:
		inventory[slot_index] = stack
		inventory_changed.emit()
		
		return true
		
	if slot_stack.item_data == stack.item_data:
		var max_stack = stack.item_data.max_stack
		var space = max_stack - slot_stack.quantity
		
		if space <= 0:
			return false
			
		var to_add = min(space, stack.quantity)
		
		slot_stack.quantity += to_add
		stack.quantity -= to_add
		inventory_changed.emit()
		
		return true
	else:
		return false
			
func has_item(item_id, amount) -> bool:
	
	var total = 0

	for item in inventory:
		if item == null:
			continue
		
		if item.stack.item_data.id == item_id:
			total += item.quantity
		
			if total >= amount:
				return true
	
	return false
	
func remove_item(item_id, amount):
	
	var remaining_to_remove = amount
	
	for i in range(inventory.size()):
		var item = inventory[i]
		
		if item == null:
			continue
			
		if item.item_data.id == item_id:
			if item.quantity > remaining_to_remove:
				item.quantity -= remaining_to_remove
				remaining_to_remove = 0
				break
			else:
				remaining_to_remove -= item.quantity
				inventory[i] = null
				
		if remaining_to_remove == 0:
			break
	
	# Signal for UI sync
	inventory_changed.emit()
	return amount - remaining_to_remove
	
func remove_from_slot(slot_index, amount_requested):

	var item = inventory[slot_index]
	
	if item == null:
		return 0
	
	var amount_to_remove = min(amount_requested, item.quantity)
		
	item.quantity -= amount_to_remove
			
	if item.quantity == 0:
		inventory[slot_index] = null 
		
	inventory_changed.emit()
	return amount_to_remove
	
## This is for Inventory UI
func get_inventory() -> Array:
	return inventory.duplicate()
	
func get_item(index):
	
	if index < 0 or index >= inventory.size():
		return null
		
	return inventory[index]
			
func set_slot(slot_index, stack: ItemStack):
	inventory[slot_index] = stack
	inventory_changed.emit()
