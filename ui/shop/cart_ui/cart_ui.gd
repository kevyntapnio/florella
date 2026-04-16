extends Control

@export var slot_scene: PackedScene
@onready var grid_container = $Background/MarginContainer/GridContainer
var cart: Cart

var slots = []

func initialize(size, cart_object):
	visible = true
	create_slots(size)
	
	cart = cart_object
	cart.cart_changed.connect(update_display)
	
func create_slots(size):
	if slot_scene == null:
		push_error("CartUI ERROR: Assign slot_scene in Editor")
		return
	
	if grid_container == null:
		push_error("CartUI ERROR: grid_container not found")
		return
		
	for i in range(size):
		var slot = slot_scene.instantiate()
		grid_container.add_child(slot)
		slots.append(slot)
		slot.slot_index = i
		
		slot.slot_clicked.connect(on_left_click)
		slot.slot_right_clicked.connect(on_right_click)
	
func on_left_click(index):
	
	cart.handle_left_click(index)
	
func on_right_click(index):
	
	cart.handle_right_click(index)
	
func update_display(total_price):
	
	update_all_slots()
	update_price_display(total_price)
		
func update_all_slots():
	
	for slot in slots:
		var index = slot.slot_index
		var item = cart.get_item(index)
		
		if item == null: 
			slot.update_slot(null, 0)
		
		else:
			var item_data = item.item_data
			var icon = item_data.icon
			var quantity = item.quantity

			slot.update_slot(icon, quantity)
		
func update_price_display(total_price):
	var current_gold = PlayerGlobalStats.get_current_gold()
	
	#temporary. no price display added to UI yet
	if total_price > current_gold:
		#price_display updates but turns red
		pass

func open_menu():
	visible = true
	
func close_menu():
	if slots == null:
		return
		
	for slot in slots:
		slot.queue_free()
		
	slots.clear()
	visible = false
