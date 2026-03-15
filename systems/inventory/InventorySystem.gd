extends Node

## temporary for debugging
var inventory_slots = [
	preload("res://SeedItems/DaisySeedItem.tres")
	]
# var inventory_slots = []
var selected_slot_index = 0

func get_selected_item():
	
	if inventory_slots.size() == 0:
		return null
		
	if selected_slot_index >= inventory_slots.size():
		return null
		
	return inventory_slots[selected_slot_index]
