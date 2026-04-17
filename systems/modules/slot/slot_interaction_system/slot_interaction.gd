extends Node

var held_stack: ItemStack = null
var source_index = -1
var source_container: SlotContainer = null

signal held_changed(held_stack)

func handle_left_click(container: SlotContainer, index):

	var item_in_slot = container.get_item(index)
	
	## if there's no held_item, and slot has a stack, pick up whole stack
	
	if held_stack == null:
		if item_in_slot != null:
			held_stack = item_in_slot
			container.set_slot(index, null)
			source_container = container
			source_index = index
			
			held_changed.emit(held_stack)
		return
		
	## if held_item exists and slot is empty, place held onto slot 
	
	if item_in_slot == null:
		container.set_slot(index, held_stack)
		clear_held()
		
		held_changed.emit(held_stack)
		return
			
	## if held_item exists and same item is in slot, try to add ##
	
	elif item_in_slot.item_data.id == held_stack.item_data.id:
		if container.add_to_slot(index, held_stack):
			clear_held()
		else:
			container.add_stack(held_stack)
			clear_held()
			
		held_changed.emit(held_stack)
		return
			
	## if held_item exists and item in slot is a different item, swap stacks
	else:
			
		var temp_stack = item_in_slot
			
		container.set_slot(index, held_stack)
			
		held_stack = temp_stack
		source_container = container
		source_index = index
			
		held_changed.emit(held_stack)
			
		return
		
func handle_right_click(container: SlotContainer, index):
	
	var item_in_slot = container.get_item(index)
	
	## if there's no held_stack and slot has a stack, pick up 1 ##
	
	if held_stack == null:
		if item_in_slot != null:
			var new_stack = ItemStack.new()
			new_stack.item_data = item_in_slot.item_data
			
			var removed = container.remove_from_slot(index, 1)
			
			new_stack.quantity = removed
			
			held_stack = new_stack
			source_index = index
			source_container = container
			held_changed.emit(held_stack)
		return
		
	## if same slot is right-clicked again, add 1 to held_stack ##
	
	if index == source_index:
		if item_in_slot != null and item_in_slot.item_data == held_stack.item_data:
			var removed = container.remove_from_slot(index, 1)
			held_stack.quantity += removed
			held_changed.emit(held_stack)
		return
	
	## if held_stack exists but a different slot is right-clicked, cancel held and return stack to source ##
	else: 
		if source_container.add_to_slot(source_index, held_stack):
			clear_held()
			held_changed.emit(held_stack)
		else:
			source_container.add_stack(held_stack)
			clear_held()
			held_changed.emit(held_stack)
		return
			
func clear_held():
	
	held_stack = null
	source_index = -1
	source_container = null
	
func cancel_held():
	
	if held_stack == null:
		return
		
	## if UI is exited or closed while held stack exists, return stack to source ##
	## try to add back to source_index in source_container
	
	var success = source_container.add_to_slot(source_index, held_stack)
	
	if success:
		clear_held()
	else:
		
		## if adding back to source_slot fails, just try adding it back anywhere
		## track leftover for now; integrate into world_item spawning later
		
		var leftover = source_container.add_stack(held_stack)
	
		if leftover.quantity > 0: 
			held_stack = leftover
		else:
			clear_held()
		
	held_changed.emit(held_stack)
