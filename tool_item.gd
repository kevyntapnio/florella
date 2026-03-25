extends ItemData

class_name ToolItem

enum ToolType {
	HOE,
	WATERING_CAN
}
@export var range: int
@export var tool_type: ToolType

func use(player_coords, target_coords):
	if target_coords == null:
		return false
	
	if not can_use(player_coords, target_coords):
		return false
		
	return target_coords.use_tool(self)

func can_use(player_coords, target_coords) -> bool:
	if target_coords == null:
		return false
			
	var dx = abs(player_coords.x - target_coords.x)
	var dy = abs(player_coords.y - target_coords.y)
	var distance = max(dx, dy)
	
	return distance <= max(dx, dy)
