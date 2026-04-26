extends Node

var surface_objects: Dictionary = {}

func register(cell, object):
	if not surface_objects.has(cell):
		surface_objects[cell] = [object]
	else:
		if object not in surface_objects[cell]:
			surface_objects[cell].append(object)
			
func unregister(cell, object):
	
	if not surface_objects.has(cell):
		return
	
	surface_objects[cell].erase(object)
	
	if surface_objects[cell].is_empty():
		surface_objects.erase(cell)
		
func get_surface_objects(cell):
	if surface_objects.has(cell):
		return surface_objects.get(cell, [])
	else:
		return []
		
