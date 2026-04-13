extends CanvasLayer

@export var slot_scene: PackedScene

@onready var grid_container = $MarginContainer/Background/MarginContainer/GridContainer

var slots: Array = []
var is_open = false
	
func initialize(shop_entries):
	
	create_slots(shop_entries)
	layer = 11
	
	open_menu()
	
func open_menu():
	TimeManager.pause_time(self)
	is_open = true
	visible = true
	
	
func close_menu():
	TimeManager.resume_time(self)
	is_open = false
	visible = false
	clear_slots()
	#cart.clear_slots()
	
func _input(event: InputEvent) -> void:
	if not is_open:
		return
		
	if event.is_action_pressed("ui_cancel"):
		close_menu()
		get_viewport().set_input_as_handled()
	
func create_slots(shop_entries):
	
	if slot_scene == null:
		push_error("ShopUI ERROR: shop_slot not assigned in Editor")
		return

	print(shop_entries)
	
	for i in range(shop_entries.size()):
		var slot = slot_scene.instantiate()
		grid_container.add_child(slot)
		slots.append(slot)
		slot.slot_index = i
		
		slot.slot_clicked.connect(on_slot_clicked)
	
	update_slots(shop_entries)
		
func on_slot_clicked(slot_index):
	print("slot clicked:", slot_index)

func clear_slots():
	if slots == null:
		return
		
	for slot in slots:
		slot.queue_free()
	
	slots.clear()
	
func update_slots(shop_entries): 
	
	for i in range(shop_entries.size()):
		var entry = shop_entries[i]
		var slot = slots[i]
		
		slot.shop_entry = entry
			
		var icon = entry.item.icon
		var price = entry.get_price()
			
		slot.update_slot(icon, price)
