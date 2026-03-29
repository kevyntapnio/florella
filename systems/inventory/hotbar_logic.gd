extends Node

var selected_index: int = 0
var hotbar_size = 10
var page = 0

signal selected_changed(selected_index) ## connects to HotbarUI

func set_selected_index(index):
	
	if index < 0 or index >= hotbar_size:
		print("Hotbar: invalid index, ignoring")
		return
	selected_index = index
	selected_changed.emit(selected_index)
	
func change_selected_index(direction):
	
	var new_index = selected_index + direction
	var wrapped_index = (new_index % hotbar_size + hotbar_size) % hotbar_size
	
	selected_index = wrapped_index
	selected_changed.emit(selected_index)
	
func get_selected_item():
	
	var item = InventorySystem.get_item(selected_index)
	
	return item
	
func get_inventory_index(slot_index):
	return slot_index + (page * hotbar_size)
	
func get_selected_item_data():
	var item = get_selected_item()
	
	if item == null:
		return
	return ItemDatabase.get_item(item["id"])
	
