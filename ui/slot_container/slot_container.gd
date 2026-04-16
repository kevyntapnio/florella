extends Control
class_name SlotContainerUI

@export var total_slots: int
@export var slot_scene: PackedScene
@export var grid_container: GridContainer

var slots: Array = []

func _ready() -> void:
	slot_scene = load("res://ui/inventory_ui/slot.tscn")
	
	create_slots()
	
func create_slots():
	
	if slot_scene == null:
		push_error("SlotContainer ERROR: slot_scene not found")
		return
		
	for i in range(total_slots):
		var slot = slot_scene.instantiate()
		grid_container.add_child(slot)
		slot.slot_index = i
		slots.append(slot)
		
		slot.slot_clicked.connect(_on_slot_clicked)
		slot.slot_right_clicked.connect(_on_slot_right_clicked)

func _on_slot_clicked():
	pass
	
func _on_slot_right_clicked():
	pass
	
func update_all_slots():
	
