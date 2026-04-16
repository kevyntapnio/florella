extends Control
class_name SlotContainerUI

@export var slot_scene: PackedScene
@export var grid_container: GridContainer

var container: SlotContainer
var slots: Array = []

func initialize(container_ref: SlotContainer):
	container = container_ref

	container.slots_changed.connect(update_all_slots)
	
func create_slots(size):
	slots.clear()
	
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

func update_all_slots():
	pass

func reset():
	if slots == null:
		return
		
	for slot in slots:
		slot.queue_free()
		
	slots.clear()
	visible = false
