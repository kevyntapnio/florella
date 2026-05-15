class_name FlowerStand
extends SlotContainer

@export var max_slots: int

var container_ui: Control

func setup(max_slots: int) -> void:
	self.max_slots = max_slots
	initialize(max_slots)
	
func can_accept_stack(stack: ItemStack) -> bool:
	return stack.item_data is FlowerData
	
func get_all_active_meanings():
	var active_meanings: Array[FlowerData.CoreMeaning]
	
	for slot in slots:
		if slot.stack == null:
			continue
			
		var data = slot.stack.item_data
		
		if not data is FlowerData:
			continue 
		
		var core_meanings = data.core_meanings
		
		for meaning in core_meanings:
			if not active_meanings.has(meaning):
				active_meanings.append(meaning)
	
	return active_meanings
	
func get_flower_inventory() -> Array:
	return slots.duplicate()
	
