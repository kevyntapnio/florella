extends Node2D

class_name GridObject

var grid_position: Vector2i

func _ready():
	await get_tree().process_frame
	
	grid_position = GridManager.get_tile_coords(global_position)
	GridManager.register_grid_object(grid_position, self)
	
func _exit_tree():
	GridManager.unregister_grid_object(grid_position, self)
