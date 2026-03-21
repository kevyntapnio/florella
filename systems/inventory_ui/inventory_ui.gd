extends CanvasLayer

@export var grid_container: GridContainer
@export var slot_scene: PackedScene

var selected_index = -1
var is_open = false
var highlight_index = -1
var held_quantity = 0
var held_id = null
var source_index = -1

signal selection_changed(highlight_index)
	
func _ready():
	slot_scene = load("res://systems/inventory_ui/inventory_slot.tscn")
	print("slot_scene")
	visible = false
	create_slots()
		
func create_slots():
	if slot_scene == null:
		print("FAILED TO LOAD SLOT SCENE")
	for i in range(30):
		var slot = slot_scene.instantiate()
		grid_container.add_child(slot)
		slot.slot_index = i
		
		## Connection to slots
		slot.slot_clicked.connect(on_slot_clicked)
		slot.slot_right_clicked.connect(on_right_click)
		
	selection_changed.emit(selected_index)
		
func toggle():
	is_open = !is_open
	visible = is_open

	#if is_open:
	#	TimeManager.pause_time(self)
	#else:
	#	TimeManager.resume_time(self)
	
	get_tree().paused = is_open
	
func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("inventory"):
		toggle()
		print("inventory toggled")

func on_slot_clicked(slot_index):
	
	highlight_index = slot_index
	
	## ----- WHEN HOLDING SOMETHING -----##
	if held_quantity > 0:
		var item_in_slot = InventorySystem.get_item(slot_index) ## remember this returns a dictionary
		
		if item_in_slot == null:
			var new_item = {"id": held_id, "quantity": held_quantity}
			InventorySystem.set_slot(slot_index, new_item)
			
			held_id = null
			held_quantity = 0
		
		elif item_in_slot["id"] == held_id:
			if InventorySystem.add_to_slot(slot_index, held_id, held_quantity):
				held_id = null
				held_quantity = 0
		
		else:
			var temp_item = item_in_slot
			var new_item = {"id": held_id, "quantity": held_quantity}
			
			InventorySystem.set_slot(slot_index, new_item)
			held_id = temp_item["id"]
			held_quantity = temp_item["quantity"]
		
		highlight_index = -1
		selection_changed.emit(highlight_index)
		return
		
	##------- WHEN NOT HOLDING ANYTHING ---------##
	if selected_index == -1:
		if InventorySystem.get_item(slot_index) != null:
			selected_index = slot_index
	else:
		if slot_index == selected_index:
			selected_index = -1 
			highlight_index = -1 ## remove highlight
		else:
			InventorySystem.swap_items(selected_index, slot_index)
			selected_index = -1
			highlight_index = -1
			
	selection_changed.emit(highlight_index)

func on_right_click(slot_index):
	var item_in_slot = InventorySystem.get_item(slot_index)
	
	if held_quantity == 0:
		if item_in_slot != null:
			source_index = slot_index
			held_id = item_in_slot["id"]
			var removed = InventorySystem.remove_from_slot(slot_index, 1)
			held_quantity += removed
	
	# If already holding
	else:
		if slot_index == source_index:
			var removed = InventorySystem.remove_from_slot(slot_index, 1)
			held_quantity += removed
		else:
			if InventorySystem.add_to_slot(source_index, held_id, held_quantity):
				pass
			else:
				InventorySystem.add_item(held_id, held_quantity)
		
			held_quantity = 0
			held_id = null
			source_index = -1
				
