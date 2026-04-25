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
		
	if not target is GridObject and not target is SpatialObject:
		return false
		
	var target_coords
	
	if target is GridObject:
		target_coords = context.target_tile
	elif target is SpatialObject:
		target_coords = context.target_cell
		
	var player_tile = context.player_tile
		
	var dx = abs(player_tile.x - target_coords.x)
	var dy = abs(player_tile.y - target_coords.y)
		
	var distance = max(dx, dy)
		
	return distance <= range

func apply_tool(target, context):
	return false
