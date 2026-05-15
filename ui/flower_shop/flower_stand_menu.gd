extends MenuBase
class_name FlowerStandMenu

@export var flower_stand_ui: FlowerStandUI

func _ready() -> void:
	layer = 15

func initialize_flower_stand(container: FlowerStand) -> void:
	assert(flower_stand_ui != null)
	
	flower_stand_ui.initialize(container)
	flower_stand_ui.create_slots(container.max_slots)
	flower_stand_ui.update_all_slots()
	
	open()
	
func _on_pre_close():
	super._on_pre_close()
	
	flower_stand_ui.clear_slots()
