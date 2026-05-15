extends Node
class_name FlowerShopManager

@export var flower_stand_menu: CanvasLayer

func open_flower_stand(stand: FlowerStandObject) -> void:
	assert (flower_stand_menu != null)
	
	var container = stand.get_flower_stand()
	flower_stand_menu.initialize_flower_stand(container)
	
