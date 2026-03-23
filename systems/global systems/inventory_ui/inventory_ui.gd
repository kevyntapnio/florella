extends CanvasLayer

@export var grid_container: GridContainer
@export var slot_scene: PackedScene

var selected_index = -1
var is_open = false
var inventory: Array = []
var slots: Array = []

signal selection_changed(selected_index) ## for slot highlight update
	
func _ready():
	slot_scene = load("res://systems/global systems/inventory_ui/inventory_slot.tscn")
	inventory = InventorySystem.get_inventory()
	
	layer = 10

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

	get_tree().paused = is_open
	
	if not is_open:
		InventoryInteraction.cancel_held()
	update_all_slots()
		
func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("inventory"):
		toggle()
		
func update_selection_visuals():
	
	for slot in slots:
		var index = slot.slot_index
		
		if index == selected_index:
			slot.set_highlight(true)
		else:
			slot.set_highlight(false)
			
func on_slot_clicked(slot_index):
	
	InventoryInteraction.handle_left_click(slot_index)
	
	if selected_index != slot_index:
		selected_index = slot_index
	else:
		selected_index = -1
		
	update_selection_visuals()
	update_all_slots()

func on_right_click(slot_index):
	
	InventoryInteraction.handle_right_click(slot_index)
		
	update_all_slots()
				
