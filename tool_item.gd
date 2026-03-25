extends ItemData

class_name ToolItem

enum ToolType {
	HOE,
	WATERING_CAN
}

@export var tool_type: ToolType

func use(target):
	if target == null:
		return false
		
	return target.use_tool(self)
