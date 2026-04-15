extends Control
class_name ShopSlot

var slot_index: int
var shop_entry: Resource

@onready var icon = $Background/Icon
@onready var price_label = $Background/PriceLabel

signal slot_clicked
signal hovered
signal unhovered

func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			accept_event()
			slot_clicked.emit(slot_index)
	
func update_slot(item_icon: Texture, price: int):
	icon.texture = item_icon
	price_label.text = str(price)
	
func _on_mouse_entered():
	hovered.emit(slot_index)
	
func _on_mouse_exited():
	unhovered.emit(slot_index)
	
