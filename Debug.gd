extends Node

func _add_items_to_inventory():
	
	InventorySystem.add_item("basic_watering_can", 1)
	InventorySystem.add_item("basic_hoe", 1)
	InventorySystem.add_item("worn_table", 3)
	PlayerGlobalStats.add_to_wallet(5000)

func _add_debug_rect(object, anchor_cell):
	var rect = ColorRect.new()
	object.add_child(rect)
	rect.size = Vector2i(16, 16)
	rect.modulate = Color(1.0, 0, 0, 0.5)
	rect.global_position = SpatialLookup.get_world_position(anchor_cell + Vector2i(1, 1))
	
	var occupied_tiles = object.get_occupied_cells(anchor_cell)
	
	for tile in occupied_tiles:
		var tile_rect = ColorRect.new()
		object.add_child(tile_rect)
		tile_rect.global_position = SpatialLookup.get_world_position(tile)
		tile_rect.modulate = Color(0.996, 0.518, 0.729, 0.549)
		tile_rect.size = Vector2i(16, 16)
		
	var origin_rect = ColorRect.new()
	object.add_child(origin_rect)
	origin_rect.size = Vector2i(4, 4)
	origin_rect.modulate = Color.BLACK
	origin_rect.global_position = object.global_position
	
