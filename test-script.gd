var slot_index
var source_index: int = -1
var held_id = null
var held_quantity = 0

func test(slot_index):
	var item_in_slot = InventorySystem.get_item(slot_index)
	
	# Not holding anything
	
	if held_quantity == 0:
		if item_in_slot != null:
			source_index = slot_index
			held_id = item_in_slot["id"]
			InventorySystem.remove_item(slot_index, 1)
			held_quantity = 1
	
	# If already holding
	else:
		
		if item_in_slot != null and held_id == item_in_slot["id"]:
			InventorySystem.remove_item(slot_index, 1)
			held_quantity += 1
		else:
			InventorySystem.add_item(slot_index, held_quantity)
			
			held_quantity = 0
			held_id = null
			source_index = -1
				
