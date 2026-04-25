extends Node2D

class_name SpatialObject

var cells: Array[Vector2i]
var is_registered:= false
		
func activate_spatial_registration(anchor_cell):
	
	print(anchor_cell)
	cells = get_occupied_cells(anchor_cell)
	register_cells()
	
func register_cells():
	for cell in cells:
		SpatialLookup.register_spatial_object(cell, self)
	
	is_registered = true
	
func _exit_tree():
	if is_registered:
		for cell in cells:
			SpatialLookup.unregister_spatial_object(cell, self)
	
func get_occupied_cells(anchor_cell: Vector2i):
	pass

func refresh_occupancy(anchor_cell):
	if not is_registered:
		return
		
	for cell in cells:
		SpatialLookup.unregister_spatial_object(cell, self)
		
	var new_cells = get_occupied_cells(anchor_cell)
	
	for cell in new_cells:
		SpatialLookup.register_spatial_object(cell, self)
		
	cells = new_cells
		
