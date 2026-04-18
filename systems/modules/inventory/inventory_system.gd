extends SlotContainer

var max_slots: int = 30

func _ready() -> void:
	initialize(max_slots)
	
func add_item(item_id, amount):
	
	var item_data = ItemDatabase.get_item(item_id)
	
	if item_data == null:
		print("INVALID ITEM", item_id)
		return
		
	var stack = ItemStack.new()
	stack.item_data = item_data
	stack.quantity = amount
	
	add_stack(stack)
	
func has_item(item_id, amount) -> bool:
	
	var total = 0

	for item in slots:
		if item == null:
			continue
		
		if item.item_data.id == item_id:
			total += item.quantity
		
			if total >= amount:
				return true
	
	return false
	
func get_inventory() -> Array:
	return slots.duplicate()
	
func get_save_data() -> Dictionary:
	
	var save_data = {
		"slots": []
	}
	
	for i in range(slots.size()):
		var slot = slots[i]
		
		if slot == null:
			continue
			
		var entry = {
			"index": i,
			"id": slot.item_data.id,
			"quantity": slot.quantity
		}
		
		save_data["slots"].append(entry)
	
	return save_data
	
func load_from_data(data: Dictionary):
	
	var saved_slots = data.get("slots", [])
	
	for entry in saved_slots:
		
		var index = entry["index"]
		var item_id = entry["id"]
		var quantity = entry["quantity"]
		
		if item_id == null:
			slots[index] = ItemStack.new()
			continue
			
		var item_data = ItemDatabase.get_item(item_id)
		
		if item_data == null:
			push_error("InvetorySystem ERROR: Could not find item_data")
			continue
			
		var stack = ItemStack.new()
		stack.item_data = item_data
		stack.quantity = quantity
		
		slots[index] = stack
		
	slots_changed.emit()
