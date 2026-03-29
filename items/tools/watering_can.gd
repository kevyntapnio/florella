extends ToolItem

class_name WateringCan

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
		
	return target.soil_state == target.SoilState.TILLED
	
func apply_tool(target, context):
	return target.interact_with_tool(self, context)
