extends Node2D

class_name GridObject

var anchor_cell: Vector2i
var is_registered:= false
var occupied_tiles = []

@export var object_footprint: Vector2i = Vector2i(1, 1)
		
func _ready():
	await get_tree().process_frame

	anchor_cell = get_anchor_cell()
	occupied_tiles = get_occupied_tiles(anchor_cell)
	
	register_all_tiles()
	is_registered = true
	
func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSFORM_CHANGED:
		update_occupancy(anchor_cell)
	
func _exit_tree():
	if is_registered:
		for tile in occupied_tiles:
			GridManager.unregister_grid_object(tile, self)

func update_occupancy(new_tile):
	
	if anchor_cell == new_tile:
		return
	
	var next_occupied_tiles = get_occupied_tiles(new_tile)
	
	for tile in occupied_tiles:
		GridManager.unregister_grid_object(tile, self)
		
	occupied_tiles = next_occupied_tiles
	anchor_cell = new_tile
	
	for tile in occupied_tiles:
		GridManager.register_grid_object(tile, self)
	
func get_anchor_cell():
	## Anchor is derived by adding 1 tile up, 1 tile to left
	## Objects grows from bottom right corner of node origin
	
	return GridManager.get_tile_coords(global_position) + Vector2i(-1, -1)

func get_occupied_tiles(anchor_cell: Vector2i) -> Array:
	
	var tiles: Array[Vector2i] = []
	var size_in_tiles = Vector2i(object_footprint / GridManager.tile_size)
	
	for x in range(size_in_tiles.x):
		for y in range(size_in_tiles.y):
			var tile = anchor_cell + Vector2i(-x, -y)
			tiles.append(tile)
			
	return tiles
			
func register_all_tiles():
	
	if not is_registered:
		for tile in occupied_tiles:
			GridManager.register_grid_object(tile, self)
		
