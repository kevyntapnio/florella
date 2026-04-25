extends Control

@onready var icon = $Icon
@onready var quantity_label = $QuantityLabel
@onready var highlight = $Highlight

signal slot_clicked(slot_index)
signal slot_right_clicked(slot_index)
signal slot_hovered(slot_index)
signal slot_unhovered(slot_index)

@export var slot_index: int

func _ready():
	highlight.hide() # default highlight state
	
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	
func update_slot(new_item, new_quantity):
	if new_item == null:
		clear_slot()
		return
		
	icon.texture = new_item
	icon.visible = true
	
	if new_quantity > 1:
		quantity_label.text = str(new_quantity)
	else:
		quantity_label.text = ""
	
func clear_slot():
	icon.visible = false
	quantity_label.text = ""
	
func _gui_input(event: InputEvent) -> void:
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			accept_event()
			slot_clicked.emit(slot_index)
			
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			accept_event()
			slot_right_clicked.emit(slot_index)

func set_highlight(is_active: bool):
	if highlight != null:
		highlight.visible = is_active
	else:
		print("INVENTORY_SLOT ERROR: highlight texture not found")
		
func _on_mouse_entered():
	#icon.scale = Vector2(1.05, 1.05)
	#slot_hovered.emit(slot_index)
	#set_highlight(true)
	
	slot_hovered.emit(slot_index)
	
func _on_mouse_exited():
	#icon.scale = Vector2(1.0, 1.0)
	#slot_hovered.emit(slot_index)
	#set_highlight(false)

	slot_unhovered.emit(slot_index)
