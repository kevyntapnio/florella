extends CanvasLayer

@onready var root = $Root
@onready var icon = $Root/Icon
@onready var quantity_label = $Root/Icon/Quantity

func _ready():
	InventoryInteraction.held_changed.connect(on_held_changed)
	
	layer = 10  # ensure on top
	
	root.visible = true
	root.size = Vector2(64, 64)

func _process(delta):
	root.position = get_viewport().get_mouse_position()
	
func on_held_changed(id, quantity):
	if quantity == 0:
		icon.visible = false
		quantity_label.visible = false
		return
	
	icon.visible = true
	quantity_label.visible = true
	
	var item = ItemDatabase.get_item(id)
	icon.texture = item.icon
	quantity_label.text = str(quantity)
		
	if quantity > 0:
		icon.texture = item.icon
		quantity_label.text = str(quantity)
		visible = true
		print
