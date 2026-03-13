extends Resource

class_name SeedItem

@export var crop_data: CropData

func use(target_tile) -> bool: 
	if target_tile == null:
		return false
		
	return target_tile.plant(crop_data)
	
