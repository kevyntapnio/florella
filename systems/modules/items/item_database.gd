extends Node

var items = {}
var crops = {}

func _ready():
	load_items_from_folder("res://data/itemdata/")
	load_crops_from_folder("res://data/cropdata/")
	
func get_item(item_id: String):
	## pulls from database: ItemData resource
	#if items array finds matching item ID
	
	if items.has(item_id):
		return items[item_id]
	else:
		push_error("ItemDabase ERROR: Item not found", item_id)
		return null
	
func load_items_from_folder(path):
	
	var dir = DirAccess.open(path)
	
	if dir == null:
		print("ItemDatabase ERROR: Failed to open folder:", path)
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
	
func load_crops_from_folder(path):
	
	var dir = DirAccess.open(path)
	
	if dir == null:
		push_error("ItemDatabase ERROR: Failed to open crop folder:", path)
	
	dir.list_dir_begin()
	
	var file_name = dir.get_next()
	
	while file_name != "":
		if file_name.ends_with(".tres"):
			
			var resource = ResourceLoader.load(path + "/" + file_name)
			
			if resource:
				crops[resource.id] = resource
				
		file_name = dir.get_next()
		
	dir.list_dir_end()
	
func get_crop(crop_id: String):
	if crops.has(crop_id):
		return crops[crop_id]
	else:
		push_error("ItemDatabase ERROR: crop_data not found:", crop_id)
		return null
		
		
