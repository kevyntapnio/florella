extends Control

@onready var icon = $Icon
@onready var quantity_label = $QuantityLabel
@onready var highlight = $Highlight
@onready var inventory_ui

signal slot_clicked(slot_index)
signal slot_right_clicked(slot_index)

var slot_index: int

func _ready():
	InventorySystem.inventory_changed.connect(update_slot)
	inventory_ui = get_tree().get_first_node_in_group("inventory_ui")
	
	if inventory_ui != null:
		inventory_ui.selection_changed.connect(on_selection_changed)
	else:
		print("ERROR: InventoryUI not found")
	update_slot()
	
	##default highlight state off
	highlight.hide()
	
func update_slot():
	
	var item = InventorySystem.get_item(slot_index)
	
	if item == null:
		clear_slot()
		return
	
	update_visual(item)
	
func clear_slot():
	icon.visible = false
	quantity_label.text = ""
	
func update_visual(item):
	var item_data = ItemDatabase.get_item(item["id"])
	
	icon.texture = item_data.icon
	icon.visible = true
	
	quantity_label.text = str(item["quantity"])
	
func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			accept_event()
			slot_clicked.emit(slot_index)
			
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			accept_event()
			slot_right_clicked.emit(slot_index)

func on_selection_changed(highlight_index):
	if highlight_index == slot_index:
		highlight.show()
	else:
		highlight.hide()
	
