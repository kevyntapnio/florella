var crop_data
##in seed item
func use(target_tile) -> bool: 
	if target_tile == null:
		return false
		
	return target_tile.plant(crop_data)
	
## in player script
func use_item():

	if closest_tile == null:
		return

	var selected_item = InventorySystem.get_selected_item()
	
	if selected_item == null:
		return
	
	selected_item.use(closest_tile)
	
	
## inventory system

extends Node

var inventory_slots = []
var selected_slot_index = 0

func get_selected_item():

	if inventory_slots.size() == 0:
		return null

	return inventory_slots[selected_slot_index]
