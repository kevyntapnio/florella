extends Node

class_name FarmVisualManager

@export var tilled_layer: TileMapLayer
@export var watered_layer: TileMapLayer

const empty_tile = Vector2i(0, 3)
const tilled_tile = Vector2i(2, 1)
const watered_tile = Vector2i(2, 1)
		
func update_tile(grid_pos: Vector2i, state):
	watered_layer.set_cell(grid_pos, 0, empty_tile)
	
	if state == "untilled":
		tilled_layer.set_cell(grid_pos, 0, empty_tile)
		
	if state == "tilled":
		tilled_layer.set_cell(grid_pos, 0, tilled_tile)
		
	if state == "watered":
		watered_layer.set_cell(grid_pos, 0, watered_tile)
		watered_layer.modulate = Color(1, 1, 1, 0.6)
