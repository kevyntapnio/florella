extends CanvasLayer

@export var shop_ui: Control
@export var cart_ui: Control
@export var shop_system: Node
@export var buy_button: Button

var is_open = false

func _ready() -> void:
	visible = false
	layer = 11
	
func open_shop_menu():
	TimeManager.pause_time(self)
	shop_ui.open_menu()
	cart_ui.open_menu()
	is_open = true
	visible = true
	
func close_shop_menu():
	TimeManager.resume_time(self)
	shop_ui.close_menu()
	cart_ui.close_menu()
	is_open = false
	visible = false
	
func _input(event: InputEvent) -> void:
	if not is_open:
		return
	
	if event.is_action_pressed("ui_cancel"):
		close_shop_menu()
		get_viewport().set_input_as_handled()
	
func _on_buy_button_pressed() -> void:
	
	if shop_system == null:
		push_error("ShopMenuUI ERROR: shop_system not assigned in Editor")
		return
	shop_system.handle_purchase_confirmation()
