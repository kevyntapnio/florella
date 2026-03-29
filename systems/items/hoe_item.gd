extends ToolItem

class_name HoeTool

func can_use(target, context) -> bool:
	if target == null:
		return false
		
	var player_tile = context.player_tile
	var target_tile = context.target_tile
	
	var dx = abs(player_tile.x - target_tile.x)
	var dy = abs(player_tile.y - target_tile.y)
	
	var distance = max(dx, dy)
	
	if distance > range: 
		return false
		
	if target.has_crop():
		return false
		
	return true
	
func apply_tool(target):
	return target.use_hoe()
