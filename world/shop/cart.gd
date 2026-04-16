extends Node
class_name Cart

var size: int = 5
var cart_items: Array = []
var max_space: int = 99
var total_price: int
var cart_ui: Control

signal cart_changed

func _ready() -> void:
	for i in range(size):
		cart_items.append(null)
	
	cart_ui.initialize(size, self)
	
func add_stack(stack):
	var price = stack.unit_price
	
	for i in range(cart_items.size()):
		if cart_items[i] == null:
			continue
		
		if cart_items[i].item_data == stack.item_data:
			var space_left = max_space - cart_items[i].quantity
			var to_add = min(space_left, stack.quantity)
			if space_left > 0:
					
				cart_items[i].quantity += to_add
				stack.quantity -= to_add
			
				if stack.quantity <= 0:
					add_to_total(to_add, price)
					cart_changed.emit(total_price)
					print(total_price)
					return
		
	if stack.quantity <= 0:
		return
		
	for i in range(cart_items.size()):
		if cart_items[i] == null:
			
			var new_stack = ItemStack.new()
			new_stack.item_data = stack.item_data
			new_stack.quantity = stack.quantity
			
			var to_add = min(max_space, stack.quantity)
			new_stack.quantity = to_add
			stack.quantity -= to_add
			
			cart_items[i] = new_stack
			add_to_total(to_add, price)
			
			cart_changed.emit(total_price)
			print(total_price)
			return
	
func add_to_total(quantity, price):
	total_price += quantity * price
	
func get_cart_items():
	var items = []
	
	for item in cart_items:
		if item == null:
			continue
		
		items.append(item)
	
	return items

func get_item(index):
	if cart_items.is_empty():
		return null
		
	return cart_items[index]

func clear_cart():
	for cart in cart_items:
		if cart == null:
			continue
		
		if cart != null:
			cart.item_data = null
			cart.quantity = 0
			
	cart_changed.emit(total_price)
	
func handle_right_click(index):
	
	var slot_stack = cart_items[index]
	
	if slot_stack == null:
		return
		
	var item_data = slot_stack.item_data
	var price = slot_stack.unit_price
	
	###--- for every right click, remove 1 from stack---###
	if item_data != null:
		slot_stack.quantity -= 1
		
		total_price -= price
		print(total_price)
		
	if slot_stack.quantity == 0:
		clear_slot(index)
	
	cart_changed.emit(total_price)
		
func clear_slot(index):
	cart_items[index] = null
	
