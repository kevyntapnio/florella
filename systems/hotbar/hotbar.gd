extends Node

var selected_index: int = 0
var hotbar_size = 10

func set_selected_index(index):
	
	print("Hotbar: set_selected_index called with:", index)
	
	if index < 0 or index >= hotbar_size:
		print("Hotbar: invalid index, ignoring")
		return
	selected_index = index
	print("Hotbar: selected_index set to:", selected_index)
	
func change_selected_index(direction):
	print("Hotbar: change_selected_index direction:", direction)
	
	var new_index = selected_index + direction
	var wrapped_index = (new_index % hotbar_size + hotbar_size) % hotbar_size
	
	selected_index = wrapped_index
	print("Hotbar: new_selected_index:", selected_index)
	print("Hotbar: raw index:", new_index, "→ wrapped:", wrapped_index)
	
func get_selected_item():
	
	var item = InventorySystem.get_item(selected_index)
	
	return item
	
	print("Hotbar: selected item:", item)
		
