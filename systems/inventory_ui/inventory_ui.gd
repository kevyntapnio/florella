extends CanvasLayer

@export var grid_container: GridContainer
@export var slot_scene: PackedScene

var selected_index = -1
var is_open = false
var highlight_index = -1
var held_quantity = 0
var held_id = null
var source_index = -1
var inventory: Array = []
var slots: Array = []

signal selection_changed(highlight_index) ## for slot highlight update
signal held_changed(held_id, held_quantity) ## for HeldItemUI (mouse cursor)
	
func _ready():
	slot_scene = load("res://systems/inventory_ui/inventory_slot.tscn")
	inventory = InventorySystem.get_inventory()

	visible = false
	create_slots()
		
func create_slots():
	if slot_scene == null:
		print("FAILED TO LOAD SLOT SCENE")
		
	for i in range(30):
		var slot = slot_scene.instantiate()
		grid_container.add_child(slot)
		slot.slot_index = i
		slots.append(slot)
			
		## ---- CONNECT TO SLOTS ----- ##
		slot.slot_clicked.connect(on_slot_clicked)
		slot.slot_right_clicked.connect(on_right_click)
	
	await get_tree().process_frame
	update_all_slots()
	selection_changed.emit(selected_index)
	
func update_all_slots():
	for slot in slots:
		var index = slot.slot_index
		var item = InventorySystem.get_item(index)
		
		if item == null: 
			slot.update_slot(null, 0)
		
		else:
			var item_data = ItemDatabase.get_item(item["id"])
			var icon = item_data.icon
			var quantity = item["quantity"]

			slot.update_slot(icon, quantity)
		
func toggle():
	is_open = !is_open
	visible = is_open
	
	held_quantity = 0
	held_changed.emit(held_id, held_quantity)

	##-------to-add later-------##
	#if is_open:
	#	TimeManager.pause_time(self)
	#else:
	#	TimeManager.resume_time(self)
	
	get_tree().paused = is_open
	
func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("inventory"):
		toggle()
		
func update_selection_visuals():
	
	for slot in slots:
		var index = slot.slot_index
		
		if index == highlight_index:
			slot.set_highlight(true)
		else:
			slot.set_highlight(false)
			
func on_slot_clicked(slot_index):
	
	highlight_index = slot_index
	
	## ----- WHEN HOLDING SOMETHING -----##
	if held_quantity > 0:
		var item_in_slot = InventorySystem.get_item(slot_index) ## note to self: this returns a dictionary
		
		if item_in_slot == null:
			var new_item = {"id": held_id, "quantity": held_quantity}
			InventorySystem.set_slot(slot_index, new_item)
			
			held_id = null
			held_quantity = 0
			held_changed.emit()
		
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
		held_changed.emit(held_id, held_quantity)
		update_selection_visuals()
		update_all_slots()
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
			
	update_selection_visuals()
	update_all_slots()

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
			
	update_all_slots()
	held_changed.emit(held_id, held_quantity)
				
