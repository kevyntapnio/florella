extends Node

signal tile_updated(grid_position: Vector2i, data)

var tiles_data: Dictionary = {}

func get_tile_data(position):
	if not tiles_data.has(position):
		tiles_data[position] = create_default_tile()
		
	return tiles_data[position]
	
func create_default_tile():
	return {
		"soil": {
			"tilled": false,
			"watered": false
		},
		"crop": null
	}

func debug_signal():
	var data = {
		"soil": {
			"tilled": true,
			"watered": true,
		},
		"crop": null
	}
	var debug_pos = Vector2i(12, 19)
	tile_updated.emit(debug_pos, data)
