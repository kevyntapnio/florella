extends CanvasLayer

var slots: Array = []

func _ready():
	Hotbar.selected_changed.connect(on_selected_changed)
	InventorySystem.inventory_changed.connect(update_all_slots)
	
	layer = 10
	
	var hbox = $MarginContainer/HotbarPanel/HBoxContainer
	if hbox:
		slots = hbox.get_children()
	else:
		print("HOTBAR_UI ERROR: Hbox not found")
		
	for slot in slots:
		slot.slot_clicked.connect(on_slot_clicked)
		slot.slot_right_clicked.connect(on_right_click)
	
	## ---- Defer call so scene can fully initialize ---- ### 
	on_selected_changed.call_deferred(Hotbar.selected_index)
	update_all_slots.call_deferred()
	
func on_selected_changed(selected_index):
	for slot in slots:
		if slot.slot_index == selected_index:
			slot.highlight.show()
		else:
			slot.highlight.hide()

func update_all_slots():
	
	for slot in slots:
		var index = Hotbar.get_inventory_index(slot.slot_index)
		var item = InventorySystem.get_item(index)
		
		if item == null: 
			slot.update_slot(null, 0)
		else:
			var item_data = ItemDatabase.get_item(item.item_data.id)
			var icon = item_data.icon
			var quantity = item.quantity

			slot.update_slot(icon, quantity)
			
func on_slot_clicked(slot_index):
	if InventoryInteraction.held_stack == null:
		Hotbar.set_selected_index(slot_index)
	else:
		var inventory_index = Hotbar.get_inventory_index(slot_index)
		InventoryInteraction.handle_left_click(inventory_index)
	
func on_right_click(slot_index):
	var inventory_index = Hotbar.get_inventory_index(slot_index)
	InventoryInteraction.handle_right_click(inventory_index)
	
	
