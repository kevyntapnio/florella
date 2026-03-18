extends Control

var item_id: String
var quantity: int

@onready var icon = $Icon
@onready var quantity_label = $QuantityLabel

func _ready():
	pass

func set_item(new_item_id, new_quantity):
	print("set item called", new_item_id, new_quantity)
	item_id = new_item_id
	quantity = new_quantity
	
	var item_data = ItemDatabase.get_item(item_id)
	
	if item_data:
		update_texture(icon.texture)
		update_counter()
		
func clear():
	item_id = ""
	quantity = 0
	icon.texture = null
	quantity_label.text = ""
	
func update_texture(texture: Texture2D):
	icon.texture = texture

func update_counter():
	if quantity > 1:
		quantity_label.text = str(quantity)
	else:
		quantity_label.text = ""
