extends GridObject

class_name FarmTile

@export var crop_scene: PackedScene
@onready var plant_spawn_point: Node2D = $PlantSpawnPoint

const STATE_PRIORITY = {
	"watered": 2,
	"tilled": 1
}

const INTERACT_PRIORITY = 1

var crop_node: Node2D = null

func _ready() -> void:
	super()
	FarmSystem.tile_updated.connect(_on_tile_updated)
	
	var data = FarmSystem.get_tile_data(anchor_cell)
	update_visual(data)
	
	### TODO: IMPORTANT. clean this up instead of relying on await
	
	await get_tree().process_frame
	update_visual(data)
	debug_rect()
	
func _on_tile_updated(tile_position: Vector2i, data: Dictionary) -> void:
	if FarmVisual == null:
		push_error("FarmTile ERROR: FarmVisualManager didn't load")
		return
		
	if tile_position != anchor_cell:
		return
	
	update_visual(data)
		
func update_visual(data: Dictionary) -> void:
	
	var state = resolve_soil_state(data["soil"])
	
	## temporary function before replacing old logic that used Enum ##
	FarmVisual.update_tile(anchor_cell, state)
	
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
	
func debug_rect():
	for tile in occupied_tiles:
		var rect = ColorRect.new()
		add_child(rect)
		rect.size = Vector2i(32, 32)
		rect.modulate = Color(1.0, 0.0, 0.0, 0.3)
		rect.global_position = GridManager.get_world_position(tile)
		
	var rect = ColorRect.new()
	add_child(rect)
	rect.size = Vector2i(4, 4)
	rect.modulate = Color(0.423, 0.865, 0.443, 0.3)
	rect.global_position = GridManager.get_world_position(visual_cell)
	
func resolve_soil_state(soil: Dictionary) -> String:
	
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
	
func interact(request: InteractionRequest) -> bool:
	var item_data = request.selected_item_data
	
	if item_data == null:
		return false
		
	if item_data is ToolItem or item_data is SeedItem:
		if handle_item_interaction(item_data):
			return true
	
	return false

func handle_item_interaction(item_data: ItemData) ->  bool:
	
	## letting FarmTile forward the correct item interaction 
	## instead of letting FarmSystem "know" about interaction rules
	## actual validation and state changes done by FarmSystem
	
	if item_data is SeedItem:
		if FarmSystem.plant(anchor_cell, item_data.crop_data):
			return true
				
	if item_data is HoeTool:
		if FarmSystem.till_tile(anchor_cell):
			return true
		
	if item_data is WateringCan:
		if FarmSystem.water(anchor_cell):
			return true
	
	return false
		
func is_currently_interactable() -> bool:
	## always interactable, even if crop node exists (watering, manually destroying crop via tool, etc.)
	## interaction score handles priority between crop and farm_tile
	return true
	
func get_interaction_score(context) -> int:
	return INTERACT_PRIORITY
	
func is_focusable():
	## NOTE: Old logic, remove after refactor
	# all interactable surfaces has this function for focused_object targeting visuals
	# farm_tile always returns 'false' because it's never a part of proximity-based interaction
	return false
	
func can_accept_item(item_data: ItemData) -> bool:
	
	var data = FarmSystem.get_tile_data(anchor_cell)
	var state = resolve_soil_state(data["soil"])
	
	if item_data is HoeTool:
		return (state == "untilled") or (state == "tilled" and data["crop"] == null)
		
	if item_data is WateringCan:
		return state == "tilled"
		
	if item_data is SeedItem:
		return state == "tilled" or state == "watered"
		
	return false
	
func spawn_crop() -> GridObject:
	if crop_scene == null:
		push_error("FarmTileTest ERROR: crop_scene not assigned in Editor")
		return null
		
	## crop is to ysort separately so it doesn't follow farm_tile's ysort
	
	var ysort = get_tree().get_first_node_in_group("ysort_world")
	
	if ysort == null:
		push_error("FarmTileTest ERROR: no node found in 'ysort_world'")
		return null
		
	var crop = crop_scene.instantiate()
	
	ysort.add_child(crop)
	crop.anchor_cell = anchor_cell
	crop.global_position = plant_spawn_point.global_position
	crop.update_occupancy(anchor_cell)
	
	return crop
