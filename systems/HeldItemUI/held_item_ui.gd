extends CanvasLayer

@onready var root = $Root
@onready var icon = $Root/Icon
@onready var quantity_label = $Root/Quantity

var inventory_ui 

func _ready():
	inventory_ui = get_tree().get_first_node_in_group("inventory_ui")
	
	if inventory_ui:
		inventory_ui.held_changed.connect(on_held_changed)
	else:
		print("HeldItemUI ERROR: InventoryUI not found")
	print("HeldItemUI READY")
	
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
		print("ICON", item.icon)
		quantity_label.text = str(quantity)
		visible = true
		print
