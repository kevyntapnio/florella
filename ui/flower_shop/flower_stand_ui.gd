extends SlotContainerUI
class_name FlowerStandUI

func _on_slot_clicked(slot_index: int):
	if SlotInteraction.held_stack and not SlotInteraction.held_stack.item_data is FlowerData:
		return
		
	SlotInteraction.handle_left_click(container, slot_index)
		
func _on_slot_right_clicked(slot_index: int):
	
	SlotInteraction.handle_right_click(container, slot_index)
	
func update_all_slots():
	for slot in slots:
		var index = slot.slot_index
		
		var item = container.get_item(index)
		
		if item == null:
			slot.update_slot(null, 0)
			continue
			
		var icon = item.item_data.icon
		var quantity = item.quantity
		
		slot.update_slot(icon, quantity)
		
func clear_slots():
	if slots.is_empty():
		return
		
	for slot in slots:
		slot.queue_free()
		
	slots.clear()
