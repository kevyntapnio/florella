extends Node

var held_id = null
var held_quantity = 0
var source_index = -1

signal held_changed(held_id, held_quantity)

func handle_left_click(inventory_index):

	var item_in_slot = InventorySystem.get_item(inventory_index)
	
	if held_quantity == 0:
		if item_in_slot != null:
			held_id = item_in_slot["id"]
			held_quantity = item_in_slot["quantity"]
			InventorySystem.set_slot(inventory_index, null)
			
			held_changed.emit(held_id, held_quantity)
		return
		
	if held_quantity > 0:
		if item_in_slot == null:
			var new_item = {"id": held_id, "quantity": held_quantity}
			InventorySystem.set_slot(inventory_index, new_item)
			clear_held()
			held_changed.emit(held_id, held_quantity)
			return
			
		elif item_in_slot["id"] == held_id:
			if InventorySystem.add_to_slot(inventory_index, held_id, held_quantity):
				clear_held()
			else:
				InventorySystem.add_item(held_id, held_quantity)
				clear_held()
			held_changed.emit(held_id, held_quantity)
			return
			
		else:
			
			var temp_item = {"id": item_in_slot["id"], "quantity": item_in_slot["quantity"]}
			var new_item = {"id": held_id, "quantity": held_quantity}
			
			InventorySystem.set_slot(inventory_index, new_item)
			
			held_id = temp_item["id"]
			held_quantity = temp_item["quantity"]
			
			held_changed.emit(held_id, held_quantity)
			
			return
		
func handle_right_click(inventory_index):
	
	var item_in_slot = InventorySystem.get_item(inventory_index)
	
	if held_quantity == 0:
		if item_in_slot != null:
			held_id = item_in_slot["id"]
			var removed = InventorySystem.remove_from_slot(inventory_index, 1)
			held_quantity += removed
			source_index = inventory_index
			held_changed.emit(held_id, held_quantity)
		return
		
	if inventory_index == source_index:
		if item_in_slot != null and item_in_slot["id"] == held_id:
			var removed = InventorySystem.remove_from_slot(inventory_index, 1)
			held_quantity += removed
			held_changed.emit(held_id, held_quantity)
		return
			
	else: # right click different item -> cancel
		if InventorySystem.add_to_slot(source_index, held_id, held_quantity):
			clear_held()
			held_changed.emit(held_id, held_quantity)
		else:
			InventorySystem.add_item(held_id, held_quantity)
			clear_held()
			held_changed.emit(held_id, held_quantity)
		return
			
func clear_held():
	
	held_id = null
	held_quantity = 0
	source_index = -1
	
	
func cancel_held():
	
	if held_quantity == 0:
		return
	else:
		if InventorySystem.add_to_slot(source_index, held_id, held_quantity):
			pass
		else:
			InventorySystem.add_item(held_id, held_quantity)
		clear_held()
		held_changed.emit(held_id, held_quantity)
		return
