extends Node2D

class_name GridObject

var grid_position: Vector2i
var is_registered:= false
		
func _ready():
	await get_tree().process_frame

	grid_position = GridManager.get_tile_coords(global_position)
	GridManager.register_grid_object(grid_position, self)
	is_registered = true
	
func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSFORM_CHANGED:
		update_grid_position()
	
func _exit_tree():
	print("exit")
	if is_registered:
		GridManager.unregister_grid_object(grid_position, self)
		print("exit")
		
func update_grid_position():
	var new_grid_pos = GridManager.get_tile_coords(global_position)
	
	if new_grid_pos == grid_position and is_registered:
		return
		
	if is_registered:
		GridManager.unregister_grid_object(grid_position, self)
		
	grid_position = new_grid_pos
	GridManager.register_grid_object(grid_position, self)
	
	is_registered = true
