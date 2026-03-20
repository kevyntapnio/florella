@onready var slot_scene 
@onready var grid_container

func create_slots():
	for i in range(30):
		slot = slot_scene.instantiate()
		grid_container.add_child(slot)
		slot.slot_index = i
		
		
