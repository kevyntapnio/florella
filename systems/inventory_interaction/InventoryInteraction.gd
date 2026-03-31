extends Node

var held_id = null
var held_stack: ItemStack = null
var source_index = -1

signal held_changed(held_stack)

func handle_left_click(inventory_index):

	var item_in_slot = InventorySystem.get_item(inventory_index)
	
	if held_stack == null:
		if item_in_slot != null:
			held_stack = item_in_slot
			InventorySystem.set_slot(inventory_index, null)
			
			held_changed.emit(held_stack)
		return
		
	if item_in_slot == null:
		InventorySystem.set_slot(inventory_index, held_stack)
		held_stack = null
		
		held_changed.emit(held_stack)
		return
			
	elif item_in_slot.item_data.id == held_stack.item_data.id:
		if InventorySystem.add_to_slot(inventory_index, held_stack):
			held_stack = null
		else:
			InventorySystem.add_stack(held_stack)
			held_stack = null
			
		held_changed.emit(held_stack)
		return
			
	else:
			
		var temp_stack = item_in_slot
			
		InventorySystem.set_slot(inventory_index, held_stack)
			
		held_stack = temp_stack
			
		held_changed.emit(held_stack)
			
		return
		
func handle_right_click(inventory_index):
	
	var item_in_slot = InventorySystem.get_item(inventory_index)
	
	if held_stack == null:
		if item_in_slot != null:
			var new_stack = ItemStack.new()
			new_stack.item_data = item_in_slot.item_data
			
			var removed = InventorySystem.remove_from_slot(inventory_index, 1)
			
			new_stack.quantity = removed
			
			held_stack = new_stack
			source_index = inventory_index
			held_changed.emit(held_stack)
		return
		
	if inventory_index == source_index:
		if item_in_slot != null and item_in_slot.item_data == held_stack.item_data:
			var removed = InventorySystem.remove_from_slot(inventory_index, 1)
			held_stack.quantity += removed
			held_changed.emit(held_stack)
		return
			
	else: # right click different item -> cancel
		if InventorySystem.add_to_slot(source_index, held_stack):
			held_stack = null
			held_changed.emit(held_stack)
		else:
			InventorySystem.add_stack(held_stack)
			held_stack = null
			held_changed.emit(held_stack)
		return
			
func clear_held():
	
	held_stack = null
	source_index = -1
	
func cancel_held():
	
	if held_stack == null:
		return
	
	var success = InventorySystem.add_to_slot(source_index, held_stack)
	
	if success and held_stack.quantity <= 0:
		held_stack = null
	else:
		var leftover = InventorySystem.add_stack(held_stack)
	
		if leftover.quantity > 0: 
			held_stack = leftover
		else:
			held_stack = null
		
	held_changed.emit(held_stack)
