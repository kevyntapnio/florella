extends Node

var items = {}

func _ready():
	load_items_from_folder("res://data/itemdata/")
	
func get_item(item_id: String):
	## pulls from database: ItemData resource
	#if items array finds matching item ID
	if items.has(item_id):
		return items[item_id]
	else:
		print("Item not found", item_id)
		return null
	
func load_items_from_folder(path):
	
	var dir = DirAccess.open(path)
	
	if dir == null:
		print("Failed to open folder:", path)
		return
		
	dir.list_dir_begin()
	
	var file_name = dir.get_next()
	
	while file_name != "":
		if file_name.ends_with(".tres"):
			
			var resource = load(path + "/" + file_name)
			
			if resource:
				items[resource.id] = resource
		
		file_name = dir.get_next()
		
	dir.list_dir_end()
	
	
