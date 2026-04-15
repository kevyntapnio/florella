extends Control

@export var slot_scene: PackedScene

@onready var grid_container = $Background/MarginContainer/GridContainer

var shop
var slots: Array = []
var is_open = false

func _ready():
	visible = true

func initialize(shop_entries):
	
	create_slots(shop_entries)
	
func open_menu():
	visible = true
	
func close_menu():
	clear_slots()
	visible = false
	
func create_slots(shop_entries):
	
	if slot_scene == null:
		push_error("ShopUI ERROR: shop_slot not assigned in Editor")
		return
	
	for i in range(shop_entries.size()):
		var slot = slot_scene.instantiate()
		grid_container.add_child(slot)
		slots.append(slot)
		slot.slot_index = i
		
		slot.slot_clicked.connect(on_slot_clicked)
		slot.hovered.connect(_on_hovered)
		slot.unhovered.connect(_on_unhovered)
	
	update_slots(shop_entries)
		
func on_slot_clicked(slot_index):
	shop.handle_left_click(slot_index)

func clear_slots():
	if slots == null:
		return
		
	for slot in slots:
		slot.queue_free()
	
	slots.clear()
	
func update_slots(shop_entries): 
	
	for i in range(shop_entries.size()):
		var entry = shop_entries[i]
		var slot = slots[i]
		
		slot.shop_entry = entry
			
		var icon = entry.item.icon
		var price = entry.get_price()
			
		slot.update_slot(icon, price)

func _on_hovered(index):
	
	var slot = slots[index]
	slot.modulate = Color(1.1, 1.1, 1.1, 1.1)
	slot.scale = Vector2(1.03, 1.03)
	
func _on_unhovered(index):
	
	var slot = slots[index]
	slot.modulate = Color(1.0, 1.0, 1.0, 1.0)
	slot.scale = Vector2i(1.0, 1.0)
