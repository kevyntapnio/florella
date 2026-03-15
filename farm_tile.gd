extends Node2D

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
	add_to_group("farm_tiles")

func plant(crop_data) -> bool:
	
	if crop_data == null: 
		print("crop_data is null")
		return false
		
	if current_crop != null:
		print("tile already has crop")
		return false
			
	if soil_state != SoilState.TILLED:
		print("soil not tilled")
		return false
		
	var crop = crop_scene.instantiate()
	print("Crop instantiated")
		
	add_child(crop)
	current_crop = crop
	crop.parent_tile = self
	crop.receive_crop_data(crop_data)
		
	return true
	
func clear_crop():
	current_crop = null
