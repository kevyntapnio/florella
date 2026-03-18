extends Node2D

@export var grid_manager: Node2D
@export var tilemap: TileMapLayer

enum SoilState {
	GRASS,
	DIRT,
	TILLED,
	WATERED
}
## IMPORTANT: default state GRASS. change to TILLED for testing
var soil_state = SoilState.TILLED

## Change this to "Crop" when Crop class is created
var current_crop: Node2D = null

## This is needed so scene can be instantiated later
@export var crop_scene: PackedScene

func _ready():

	var coords = grid_manager.get_tile_coords(global_position)
	grid_manager.register_grid_object(coords, self)

func plant(crop_data) -> bool:
	
	if crop_data == null: 
		return false
		
	if current_crop != null:
		print("tile already has crop")
		return false
			
	if soil_state != SoilState.TILLED:
		return false
		
	var crop = crop_scene.instantiate()
		
	add_child(crop)
	current_crop = crop
	crop.initialize(crop_data, self)
		
	return true
	
func interact(item):
	
	## Handle crop first
	if current_crop != null:
		current_crop.on_interact(item)
		return
		
	## If no crop, check for item
	if item == null:
		return
		
	var item_data = ItemDatabase.get_item(item["id"])
	
	if item_data == null:
		return
		
	item_data.use(self)
		
func clear_crop():
	current_crop = null

func _exit_tree():
	var coords = grid_manager.get_tile_coords(global_position)
	grid_manager.unregister_grid_object(coords)
