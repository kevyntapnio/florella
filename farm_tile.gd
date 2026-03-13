extends Node2D

enum SoilState {
	GRASS,
	DIRT,
	TILLED,
	WATERED
}
var soil_state = SoilState.GRASS
var current_crop: Node2D = null

@export var crop_scene: PackedScene

func plant(crop_data):
	
	if crop_data == null: 
		return false
		
	if current_crop != null:
		return false
			
	if soil_state != SoilState.TILLED:
		return false
		
		var crop = crop_scene.instantiate()
		
		add_child(crop)
		current_crop = crop
		crop.parent_tile = self
		crop.receive_crop_data(crop_data)
		
		return true
	
	
