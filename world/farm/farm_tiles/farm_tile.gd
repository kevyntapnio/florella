extends GridObject

class_name FarmTile

@export var tilemap: TileMapLayer
@export var farm_visual_manager: FarmVisualManager
@export var crop_scene: PackedScene

const STATE_PRIORITY = {
	"watered": 2,
	"tilled": 1
}

const INTERACT_PRIORITY = 1

var crop_node: Node2D = null

func _ready():
	FarmSystem.tile_updated.connect(_on_tile_updated)
	await super()
	
	var data = FarmSystem.get_tile_data(grid_position)
	update_visual(data)
	
func _on_tile_updated(tile_position, data):
	if farm_visual_manager == null:
		push_error("FarmTileTest ERROR: FarmVisualManager not assigned in Editor!")
		return
		
	if tile_position != grid_position:
		return
	
	update_visual(data)
		
func update_visual(data):
	
	var state = resolve_soil_state(data["soil"])
	
	## temporary function before replacing old logic that used Enum ##
	farm_visual_manager.update_tile(grid_position, state)
	
	var crop_data = data["crop"]
	
	## if no crop currently exists, make sure to clear
	if crop_data == null:
		if crop_node != null:
			crop_node.queue_free()
			crop_node = null
		return
	
	## spawn crop if crop_data exists and crop is missing
	if crop_node == null:
		crop_node = spawn_crop()
		
	crop_node.update_visual(crop_data)
	
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
	
	return best_state
	
func interact(item, context):
	if item == null:
		return
		
	## Item runs validation logic within itself for range check, etc.
	if item is ToolItem or item is SeedItem:
		item.use(self, context)

func interact_with_tool(item, context):
	
	## letting FarmTile forward the correct item interaction instead of letting FarmSystem "know" about interaction rules
	## actual validation and state changes done by FarmSystem
	if item is HoeTool:
		FarmSystem.till_tile(grid_position)
		
	if item is WateringCan:
		FarmSystem.water(grid_position)
		
	
func get_interaction_score(context):
	return INTERACT_PRIORITY
	
func is_focusable():
	# all interactable surfaces has this function for focused_object targeting visuals
	# farm_tile always returns 'false' because it's never a part of proximity-based interaction
	return false
	
func can_accept_item(item, context) -> bool:
	## This function is used for updating TileHighlight logic only
	
	var data = FarmSystem.get_tile_data(grid_position)
	var state = resolve_soil_state(data["soil"])
	
	## allow HoeTool to undo tilled state 
	if item is HoeTool:
		return (state == "untilled") or (state == "tilled" and data["crop"] == null)
		
	## remove tile_highlight when tile has already been watered
	if item is WateringCan:
		return state == "tilled"
		
	if item is SeedItem:
		return state == "tilled" or state == "watered"
		
	return false
	
func spawn_crop():
	if crop_scene == null:
		push_error("FarmTileTest ERROR: crop_scene not assigned in Editor")
		return null
		
	## crop is to ysort separately so it doesn't follow farm_tile's ysort
	
	var ysort = get_tree().get_first_node_in_group("ysort_world")
	
	if ysort == null:
		push_error("FarmTileTest ERROR: no node found in 'ysort_world'")
		return null
		
	var crop = crop_scene.instantiate()
	
	var global_pos = GridManager.get_world_position(grid_position)
	crop.grid_position = grid_position
	crop.global_position = global_pos
	ysort.add_child(crop)
	
	return crop
