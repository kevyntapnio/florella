extends ItemData

class_name ToolItem

@export var range: int

func use(target, context):
	
	if target == null:
		return false
	
	if not can_use(target, context):
		return false
		
	return apply_tool(target)

func can_use(target, context) -> bool:
	return false

func apply_tool(target):
	return false
