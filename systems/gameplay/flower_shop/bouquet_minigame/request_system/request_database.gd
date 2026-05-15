class_name RequestDatabase
extends RefCounted

var request_data: Array[RequestData] = []

func setup():
	var path = "res://data/request_data/"
	var dir = DirAccess.open(path)
	
	if dir == null:
		print("RequestDatabase ERROR: Failed to open folder:", path)
		return
		
	dir.list_dir_begin()
	
	var file_name = dir.get_next()
	
	while file_name != "":
		if file_name.ends_with(".tres"):
			
			var resource = load(path + "/" + file_name)
			
			if resource:
				request_data[resource.id] = resource
		
		file_name = dir.get_next()
		
	dir.list_dir_end()

func get_requests() -> Array[RequestData]:
	return request_data.duplicate()
