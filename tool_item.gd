extends ItemData

class_name ToolItem

enum ToolType {
	HOE,
	WATERING_CAN
}
@export var range: int
@export var tool_type: ToolType

func use(target, context):
	
	if target == null:
		return false
	
	if not can_use(target, context):
		return false
		
	return target.use_tool(self)

func can_use(target, context) -> bool:
	var player = context.player_tile
	var target_coords = context.target_tile
	
	if target == null:
		return false
	
	var dx = abs(player.x - target_coords.x)
	var dy = abs(player.y - target_coords.y)
	
	var distance = max(dx, dy)
	
	if distance > range:
		return false
		
	match tool_type:
		ToolType.HOE:
			if target.current_crop:
				return false
			return true
		ToolType.WATERING_CAN:
			return target.is_tilled()
	
	return false
