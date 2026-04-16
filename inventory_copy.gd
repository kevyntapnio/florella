extends Control

@export var slot_scene: PackedScene
@export var grid_container: GridContainer

var slots: Array = []

func initialize():
	InventorySystem.inventory_changed.connect(_update_all_slots)
	
	var inventory = InventorySystem.get_inventory()
	
	if slot_scene == null:
		push_error("InventoryCopy ERROR: slot_scene not assigned in Editor")
		return
		
	if grid_container == null:
		push_error("InventoryCopy ERROR: grid_container not assigned in Editor")
		
	for i in range(inventory.size()):
		var slot = slot_scene.instantiate()
		grid_container.add_child(slot)
		slots.append(slot)
		slot.slot_index = i
		
		slot.slot_clicked.connect(_on_slot_clicked)
		
	_update_all_slots()
	
func _on_slot_clicked(slot_index):
	
	InventoryInteraction.handle_left_click(slot_index)
	
func open_menu():
	visible = true
	
func close_menu():
	for slot in slots:
		slot.queue_free()
		
	slots.clear()
	
func _update_all_slots():
		
	for slot in slots:
		var index = slot.slot_index
		var item = InventorySystem.get_item(index)
		
		if item == null: 
			slot.update_slot(null, 0)
		
		else:
			var item_data = item.item_data
			var icon = item_data.icon
			var quantity = item.quantity

			slot.update_slot(icon, quantity)
	
