	
	for i in range(inventory.size()):
		var slot = inventory[i]
		var current_stack = slot.stack
		
		if current_stack == null:
			continue
		
		if current_stack.item_data == stack.item_data:
			var max_stack = stack.item_data.max_stack
			var space = max_stack - current_stack.quantity
				
			if space > 0:
				var to_add = min(space, stack.quantity)
			
				current_stack.quantity += to_add
				stack.quantity -= to_add
				
				if stack.quantity <= 0:
					return stack
			
	for i in range(inventory.size()):
		var slot = inventory[i]
			
		if slot.stack == null:
			slot.stack = ItemStack.new()
			slot.stack.item_data = stack.item_data
			
			var to_add = min(stack.item_data.max_stack, stack.quantity)
			slot.stack.quantity = to_add
			stack.quantity -= to_add
			
			if stack.quantity <= 0:
				return stack
	
	return stack
