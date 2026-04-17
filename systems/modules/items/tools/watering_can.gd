extends ToolItem

class_name WateringCan
	
func apply_tool(target, context):
	return target.interact_with_tool(self, context)
