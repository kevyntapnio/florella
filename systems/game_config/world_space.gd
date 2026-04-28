class_name WorldSpace
extends RefCounted

const LOGIC_GRID_SIZE = 32
const INTERACTION_CELL_SIZE = 16

static func world_to_interaction_cell(pos: Vector2) -> Vector2i:
	return Vector2i(pos / INTERACTION_CELL_SIZE)
