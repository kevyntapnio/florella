extends GridObject

## temporary reference 
@export var farm_visual_manager: FarmVisualManager
	
const STATE_PRIORITY = {
	"watered": 2,
	"tilled": 1
}
const INTERACT_PRIORITY = 1

func _ready():
	FarmSystem.tile_updated.connect(_on_tile_updated)
	await super()
	
	var data = FarmSystem.get_tile_data(grid_position)
	update_visual(data)
	
	## - temporary - ##
	FarmSystem.debug_signal()
	
func _on_tile_updated(tile_position, data):
	if farm_visual_manager == null:
		push_error("FarmTileTest ERROR: FarmVisualManager not assigned in Editor!")
		
	if tile_position != grid_position:
		return
	
	update_visual(data)
		
func update_visual(data):
	
	var soil = data["soil"]
	var state = resolve_soil_state(soil)
	
	## temporary function before replacing old logic that used Enum ##
	farm_visual_manager.update_tile_debug(grid_position, state)
	
func resolve_soil_state(soil: Dictionary):
	
	var best_state = null
	var best_priority = -1
	
	for state in soil:
		if not soil[state]:
			continue
			
		var priority = STATE_PRIORITY.get(state, 0)
		
		if priority > best_priority:
			best_priority = priority
			best_state = state
	
	print(best_state)
	return best_state
	
func interact(item, context):
	pass
	
func get_interaction_score():
	return INTERACT_PRIORITY
	
func is_focusable():
	return false
