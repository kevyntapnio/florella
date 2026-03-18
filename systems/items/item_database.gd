extends Node

var items = {
	"daisy": preload("res://data/itemdata/daisy.tres"), 
	"daisy_seed": preload("res://data/itemdata/daisy_seed.tres")
	}

func get_item(item_id: String):
	## pulls from database: ItemData resource
	#if items array finds matching item ID
	if items.has(item_id):
		return items[item_id]
	else:
		print("Item not found", item_id)
		return null
	
