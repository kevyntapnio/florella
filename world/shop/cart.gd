extends Node
class_name Cart

var size: int = 5
var cart_items: Array = []
var max_space: int = 99
var total_price: int

signal cart_changed

func _ready() -> void:
	for i in range(size):
		cart_items.append(null)

func add_stack(stack, price):

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
					print(cart_items)
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
			
			print(cart_items)
			return
	
func add_to_total(quantity, price):
	total_price += quantity * price
	print(total_price)
	
func get_cart_items():
	var items = []
	
	for item in cart_items:
		if item == null:
			continue
		
		items.append(item)
	
	return items
