@tool
extends TileMapLayer

@export_group("Display Layers")
@export var dirt_layer: TileMapLayer

@export_group("Settings")
@export var always_update := false
@export var update_visuals := false

const DISPLAY_SOURCE_ID := 1
const LOGIC_DIRT_ATLAS := Vector2i(2, 1)
const DEFAULT_DISPLAY_ATLAS := Vector2i(0, 3)

const MASK_TO_ATLAS := {
	1: Vector2i(3, 3),
	2: Vector2i(0, 2),
	3: Vector2i(1, 2),
	4: Vector2i(0, 0),
	5: Vector2i(3, 2),
	6: Vector2i(2, 3),
	7: Vector2i(3, 1),
	8: Vector2i(1, 3),
	9: Vector2i(0, 1),
	10: Vector2i(1, 0),
	11: Vector2i(2, 2),
	12: Vector2i(3, 0),
	13: Vector2i(2, 0),
	14: Vector2i(1, 1),
	15: Vector2i(2, 1),
}

const DISPLAY_OFFSETS := [
	Vector2i(0, 0),
	Vector2i(1, 0),
	Vector2i(0, 1),
	Vector2i(1, 1),
]

func _process(_delta: float) -> void:
	if not Engine.is_editor_hint():
		return

	if not always_update and not update_visuals:
		return

	sync_layers()
	update_visuals = false

func sync_layers() -> void:
	if dirt_layer == null:
		return

	dirt_layer.clear()

	var cells_to_update := {}

	for logic_cell in get_used_cells():
		for offset in DISPLAY_OFFSETS:
			cells_to_update[logic_cell + offset] = true

	for display_cell in cells_to_update.keys():
		_update_tile(display_cell)

func _update_tile(cell: Vector2i) -> void:
	var mask := _get_mask(cell)

	if mask == 0:
		dirt_layer.set_cell(cell, DISPLAY_SOURCE_ID, DEFAULT_DISPLAY_ATLAS)
		return

	if not MASK_TO_ATLAS.has(mask):
		dirt_layer.erase_cell(cell)
		return

	dirt_layer.set_cell(cell, DISPLAY_SOURCE_ID, MASK_TO_ATLAS[mask])

func _get_mask(cell: Vector2i) -> int:
	var mask := 0

	if _is_dirt(cell + Vector2i(-1, -1)):
		mask |= 1
	if _is_dirt(cell + Vector2i(0, -1)):
		mask |= 2
	if _is_dirt(cell + Vector2i(-1, 0)):
		mask |= 4
	if _is_dirt(cell + Vector2i(0, 0)):
		mask |= 8

	return mask

func _is_dirt(cell: Vector2i) -> bool:
	return get_cell_atlas_coords(cell) == LOGIC_DIRT_ATLAS
