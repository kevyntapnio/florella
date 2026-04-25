extends SlotContainer
class_name SellContainer

var container_ui

var max_slots: int = 5

func _ready() -> void:
	initialize(max_slots)

func get_sell_items():
	var sell_items = []
	
	for slot in slots:
		if slot == null:
			continue
		
		sell_items.append(slot)
	
	return sell_items
	
func get_total_price():
	var sell_items = get_sell_items()
	var total:= 0
	
	for item in sell_items:
		total += item.item_data.sell_price * item.quantity
		
	return total

func reset_session():
	for i in range(slots.size()):
		slots[i] = null
		
	slots_changed.emit()
	container_ui.update_price_display()
	
func handle_unsold_items():
	
	for i in range(slots.size()):
		var item = slots[i]
		if item == null:
			continue 
			
		InventorySystem.add_stack(item)
		slots[i] = null
		
	slots_changed.emit()
	
		
func is_empty():
	return get_sell_items().is_empty()
