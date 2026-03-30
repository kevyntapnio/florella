extends GridObject

class_name FarmTile

@export var tilemap: TileMapLayer
@export var farm_visual_manager: FarmVisualManager

enum SoilState {
	GRASS,
	UNTILLED,
	TILLED,
	WATERED
}

var soil_state = SoilState.UNTILLED

## Change this to "Crop" when Crop class is created
var current_crop: Node2D = null

## This is needed so scene can be instantiated later
@export var crop_scene: PackedScene

func _ready():
	super()
	TimeManager.day_ended.connect(on_day_ended)
	
func on_day_ended():
	if soil_state == SoilState.WATERED:
		await get_tree().process_frame
		soil_state = SoilState.TILLED 
		update_visual()

func plant(crop_data) -> bool:
	
	if crop_data == null: 
		return false
		
	if current_crop != null:
		return false
			
	if soil_state != SoilState.TILLED and soil_state != SoilState.WATERED:
		return false
		
	var crop = crop_scene.instantiate()
	var ysort = get_tree().get_first_node_in_group("ysort_world")

	ysort.add_child(crop)
	
	crop.global_position = global_position
	current_crop = crop
	crop.initialize(crop_data, self)
		
	return true
	
func get_interaction_score(context):
	return 1
	
func interact(item, context):
		
	if item == null:
		return
	
	if item is ToolItem:
		interact_with_tool(item, context)
		return
	
	if item is SeedItem:
		item.use(self, context)
		return
		
func interact_with_tool(tool, context):

	if tool is HoeTool:
		use_hoe()
	elif tool is WateringCan:
		water()
		
func can_accept_item(item, context):
	
	if item == null:
		return false
		
	if item is HoeTool: 
		return soil_state == SoilState.UNTILLED or (is_tilled() and current_crop == null)
		
	if item is WateringCan:
		return soil_state == SoilState.TILLED
	
	if item is SeedItem:
		return is_tilled() and current_crop == null
		
	return false
func use_hoe():
	
	if soil_state == SoilState.UNTILLED:
		soil_state = SoilState.TILLED
		update_visual()
		return true
		
	elif is_tilled():
		if current_crop != null:
			return false
			
		soil_state = SoilState.UNTILLED
		update_visual()
		return true
	
	return false

func water():
	if soil_state == SoilState.TILLED:
		soil_state = SoilState.WATERED
		update_visual()
		return true
	
	return false
		
func clear_crop():
	current_crop = null
	
func is_watered() -> bool:
	if soil_state == SoilState.WATERED:
		return true
	else:
		return false
		
func is_tilled() -> bool:
	return soil_state == SoilState.TILLED or soil_state == SoilState.WATERED
		
func has_crop():
	return current_crop != null
	
func update_visual():
	
	farm_visual_manager.update_tile(grid_position, soil_state)
	
func is_focusable():
	return false
