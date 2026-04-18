extends GridObject

const INTERACTION_PRIORITY = 10
@onready var sprite = $Sprite2D

	
func interact(item, context):
	if FarmSystem.harvest(grid_position):
		play_feedback()
	
func is_focusable(item, context):
	pass
	
func update_visual(crop_state):
	
	var crop_id = crop_state["crop_id"]
	var resource = crop_state["resource"]
	
	if resource == null:
		push_error("Crop ERROR: crop_data resource missing in crop_state")
		return
		
	var stage = crop_state["growth_stage"]
	
	if stage >= resource.stages.size():
		push_error("Crop ERROR: Invalid growth stage")
		return
		
	sprite.texture = resource.stages[stage].texture
	
func play_feedback():
	pass
