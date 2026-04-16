extends CanvasLayer

@onready var root = $Root
@onready var icon = $Root/Icon
@onready var quantity_label = $Root/Icon/Quantity

func _ready():
	SlotInteraction.held_changed.connect(on_held_changed)
	
	layer = 11  # ensure on top
	
	root.visible = true
	root.size = Vector2(64, 64)

func _process(delta):
	root.position = get_viewport().get_mouse_position()
	
func on_held_changed(stack: ItemStack):
	if stack == null:
		icon.visible = false
		quantity_label.visible = false
		return
	
	if stack.quantity == 0:
		icon.visible = true
		quantity_label.visible = true
		return
		
	icon.visible = true
	quantity_label.visible = true
	
	var item = stack.item_data
		
	icon.texture = item.icon
	quantity_label.text = str(stack.quantity)
