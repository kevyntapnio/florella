extends UsableItem

class_name ToolItem

func use(target, context):
	
	if target == null:
		return false
	
	if not is_in_range(target, context):
		return false
		
	return apply_tool(target, context)

func is_in_range(target, context) -> bool:
	if target == null:
		return false
		
	var player_tile = context.player_tile
	var target_tile = context.target_tile
	
	var dx = abs(player_tile.x - target_tile.x)
	var dy = abs(player_tile.y - target_tile.y)
	
	var distance = max(dx, dy)
	
	return distance <= range

func apply_tool(target, context):
	return false
