extends Node2D

class_name GridObject

var visual_cell: Vector2i
var anchor_cell: Vector2i
var is_registered:= false
var occupied_tiles = []

@export var object_footprint: Vector2i = Vector2i(1, 1)
		
func _ready():
	
	anchor_cell = get_anchor_cell()
	occupied_tiles = get_occupied_tiles(anchor_cell)
	visual_cell = get_visual_cell()
	
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
	## TODO: IMPORTANT!!!
	## Finalize coordinate semantics after DecorSystem has been added back
	
	return GridManager.get_tile_coords(global_position) + Vector2i(-1, -1)
	
func get_visual_cell():
	return GridManager.get_tile_coords(global_position)

func get_occupied_tiles(anchor_cell: Vector2i) -> Array:

	var tiles: Array[Vector2i] = []
	var size_in_tiles = object_footprint
	
	for x in range(size_in_tiles.x):
		for y in range(size_in_tiles.y):
			var tile = anchor_cell + Vector2i(-x, -y)
			tiles.append(tile)
			
	return tiles
			
func register_all_tiles():
	
	if not is_registered:
		for tile in occupied_tiles:
			GridManager.register_grid_object(tile, self)
		
func get_interaction_zone() -> Array[Vector2i]:
	
	if occupied_tiles.is_empty():
		push_error("GridObject ERROR: occupied_tiles missing")
		return []
		
	var interaction_tiles: Array[Vector2i] = []
	
	var subdivision_ratio = WorldSpace.LOGIC_GRID_SIZE / WorldSpace.INTERACTION_CELL_SIZE
	
	for tile in occupied_tiles:
		var x = tile.x * subdivision_ratio
		var y = tile.y * subdivision_ratio
		
		interaction_tiles.append(Vector2i(x, y))
		interaction_tiles.append(Vector2i(x + 1, y))
		interaction_tiles.append(Vector2i(x, y + 1))
		interaction_tiles.append(Vector2i(x + 1, y + 1))
		
	return interaction_tiles
