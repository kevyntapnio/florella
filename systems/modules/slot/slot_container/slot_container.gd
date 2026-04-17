extends Node
class_name SlotContainer

signal slots_changed

var slots: Array = []

func initialize(container_size):
	slots.clear()
	
	for i in range(container_size):
		slots.append(null)
	
func add_stack(stack):

	for i in range(slots.size()):
		if slots[i] == null:
			continue
			
		if slots[i].item_data == stack.item_data:
			var max_stack = stack.item_data.max_stack
			var space = max_stack - slots[i].quantity
				
			if space > 0:
				var to_add = min(space, stack.quantity)
			
				slots[i].quantity += to_add
				slots_changed.emit()
				
				stack.quantity -= to_add
				if stack.quantity <= 0:
					return stack
			
	for i in range(slots.size()):
		if slots[i] == null:
			var new_stack = ItemStack.new()
			new_stack.item_data = stack.item_data
			
			var to_add = min(stack.item_data.max_stack, stack.quantity)
			new_stack.quantity = to_add
			
			slots[i] = new_stack
			slots_changed.emit()
			
			stack.quantity -= to_add
			
			if stack.quantity <= 0:
				return stack
		
	return stack
	
func add_to_slot(slot_index, stack: ItemStack) -> bool:
	var slot_stack = slots[slot_index]
	
	if slot_stack == null:
		slots[slot_index] = stack
		slots_changed.emit()
		
		return true
		
	if slot_stack.item_data == stack.item_data:
		var max_stack = stack.item_data.max_stack
		var space = max_stack - slot_stack.quantity
		
		if space <= 0:
			return false
			
		var to_add = min(space, stack.quantity)
		
		slot_stack.quantity += to_add
		stack.quantity -= to_add
		slots_changed.emit()
		
		return true
	else:
		return false
			
func remove_item(item_id, amount):
	
	var remaining_to_remove = amount
	
	for i in range(slots.size()):
		var item = slots[i]
		
		if item == null:
			continue
			
		if item.item_data.id == item_id:
			if item.quantity > remaining_to_remove:
				item.quantity -= remaining_to_remove
				remaining_to_remove = 0
				break
			else:
				remaining_to_remove -= item.quantity
				slots[i] = null
				
		if remaining_to_remove == 0:
			break
	
	# Signal for UI sync
	slots_changed.emit()
	return amount - remaining_to_remove
	
func remove_from_slot(slot_index, amount_requested):

	var item = slots[slot_index]
	
	if item == null:
		return 0
	
	var amount_to_remove = min(amount_requested, item.quantity)
		
	item.quantity -= amount_to_remove
			
	if item.quantity == 0:
		slots[slot_index] = null 
		
	slots_changed.emit()
	return amount_to_remove
	
func get_item(index):
	
	if index < 0 or index >= slots.size():
		return null
		
	return slots[index]
			
func set_slot(slot_index, stack: ItemStack):
	slots[slot_index] = stack
	slots_changed.emit()
