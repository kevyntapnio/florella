extends SlotContainerUI
class_name SellContainerUI

var max_slots = 5
@export var price_label: Label

func _ready() -> void:
	create_slots(max_slots)
	
func _on_slot_clicked(slot_index):
	
	## Only allow sellable items to be placed 
	var stack = SlotInteraction.held_stack
	
	if stack != null:
		if not stack.item_data.is_sellable:
			return
	
	SlotInteraction.handle_left_click(container, slot_index)
	
	update_all_slots()
	update_price_display()
	
func _on_slot_right_clicked(slot_index):
	
	SlotInteraction.handle_right_click(container, slot_index)
	
	update_all_slots()
	update_price_display()
	
func update_all_slots():
	
	## loop through slots to get item from index
	for slot in slots: 
		var index = slot.slot_index
		var item = container.get_item(index)
		
		if item == null:
			slot.update_slot(null, 0)
			continue
			
		var icon = item.item_data.icon
		var quantity = item.quantity
		
		slot.update_slot(icon, quantity)
		
func update_price_display():
	if price_label == null:
		push_error("ShippingBinUI: price_label not assigned in Editor")
		return
	
	var total = container.get_total_price()
	price_label.text = "Total:  " + str(total)
	
