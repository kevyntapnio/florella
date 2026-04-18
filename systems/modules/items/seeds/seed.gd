extends UsableItem

class_name SeedItem

@export var crop_data: CropData

func use(target, context):
	if not can_use(target, context):
		return false
		
	if target == null:
		return false
		
	if crop_data == null:
		return false
		
	var planted = FarmSystem.plant(target.grid_position, crop_data)
	
	if planted:
		InventorySystem.remove_item(id, 1)
	
	return planted

func can_use(target, context):
	if target == null:
		return false
		
	var player_tile = context.player_tile
	var target_tile = context.target_tile
	
	var dx = abs(player_tile.x - target_tile. x)
	var dy = abs(player_tile.y - target_tile.y)
	
	var distance = max(dx, dy)
	
	if distance > range:
		return false
		
	if not FarmSystem.is_tilled(target.grid_position): 
		return false
	
	return true
	
func is_in_range(target, context):
	pass
