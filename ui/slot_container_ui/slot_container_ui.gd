extends Control
class_name SlotContainerUI

@export var slot_scene: PackedScene
@export var grid_container: GridContainer

var container: SlotContainer
var slots: Array = []

func create_slots(size):
	
	if slot_scene == null or grid_container == null:
		push_error("SlotContainerUI ERROR: assign slot_scene or grid_container in Editor")
		
	for i in range(size):
		var slot = slot_scene.instantiate()
		grid_container.add_child(slot)
		slot.slot_index = i
		slots.append(slot)
		
		slot.slot_clicked.connect(_on_slot_clicked)
		slot.slot_right_clicked.connect(_on_slot_right_clicked)
		
func _on_slot_clicked(slot_index):
	pass
	
func _on_slot_right_clicked(slot_index):
	pass
