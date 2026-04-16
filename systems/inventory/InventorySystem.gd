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
