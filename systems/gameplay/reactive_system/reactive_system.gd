class_name ReactiveSystem
extends Node

var reactive_objects: Array = []
var closest_reactable

func register_reactable(object: Node2D):
	if not reactive_objects.has(object):
		reactive_objects.append(object)

func unregister_reactable(object: Node2D):
	if reactive_objects.has(object):
		reactive_objects.erase(object)
		
#func find_closest_reactable():
	#
	##for object in reactive_objects:
		##if 
	
