extends Node2D

class_name FarmTile

@export var tilemap: TileMapLayer
@export var farm_visual_manager: FarmVisualManager

var coords: Vector2i

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
	
	TimeManager.day_ended.connect(on_day_ended)
	
	await get_tree().process_frame
	coords = GridManager.get_tile_coords(global_position)
	GridManager.register_grid_object(coords, self)
	
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
	
func interact(item, context):
	
	## Handle crop first
	if current_crop != null:
		if current_crop.on_interact(item, context): # returns a bool. if false, let farmtile interact
			return
		
	## if hands are empty, do nothing
	if item == null:
		return 
		
	var item_data = ItemDatabase.get_item(item["id"])
	
	if item_data == null:
		print("FARM TILE ERROR: item used not in database")
		return 
	
	if item_data is SeedItem:
		item_data.use(self, context)
		return
		
	if item_data is ToolItem:
		item_data.use(self, context)
		return
	
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

func _exit_tree():
	GridManager.unregister_grid_object(coords)
	
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
	
	farm_visual_manager.update_tile(coords, soil_state)
	
