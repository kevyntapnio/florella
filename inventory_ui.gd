extends SlotContainerUI
class_name InventoryUI

var selected_index = -1

signal selection_changed(selected_index)

func _ready():
	container = InventorySystem
	
	var inventory = InventorySystem.get_inventory()
	create_slots(inventory.size())
	
	await get_tree().process_frame
	
	update_all_slots()
	selection_changed.emit(selected_index)

func update_all_slots():
	for slot in slots:
		var index = slot.slot_index
		
		var item = InventorySystem.get_item(index)
		
		if item == null:
			slot.update_slot(null, 0)
			continue
			
		var icon = item.item_data.icon
		var quantity = item.quantity
		
		slot.update_slot(icon, quantity)
		
func update_selection_visuals():
	
	for slot in slots:
		var index = slot.slot_index
		
		if index == selected_index:
			slot.set_highlight(true)
		else:
			slot.set_highlight(false)

func _on_slot_clicked(slot_index):
	
	SlotInteraction.handle_left_click(InventorySystem, slot_index)
	
	update_selection_visuals()
	update_all_slots()
	
func _on_right_click(slot_index):

	SlotInteraction.handle_right_click(InventorySystem, slot_index)

	update_all_slots()
	
