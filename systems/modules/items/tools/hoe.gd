extends ToolItem

class_name HoeTool
	
func apply_tool(target, context):
	return target.interact_with_tool(self, context)
