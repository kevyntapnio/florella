extends ItemData

class_name SeedItem

@export var crop_data: CropData

func use(player_tile, target):
	if target == null:
		return false
		
	if crop_data == null:
		return false
		
	var planted = target.plant(crop_data)
	
	if planted:
		InventorySystem.remove_item(id, 1)
	
	return planted
