extends Node2D
class_name BuildSession

var decor_factory: DecorFactory
var placement_validator: PlacementValidator
var y_sort: Node

var current_decor: DecorObject = null
var current_hovered_cell: Vector2i

func setup(decor_factory_ref: DecorFactory, placement_validator_ref: PlacementValidator, y_sort_ref: Node) -> void:
	
	decor_factory = decor_factory_ref
	placement_validator = placement_validator_ref
	y_sort = y_sort_ref
	
func initialize_build_session(decor_data: DecorData) -> void:
	assert(y_sort != null)
	
	var decor = decor_factory.create_decor(decor_data)
	y_sort.add_child(decor)
	
	current_decor = decor
	
func _process(delta: float) -> void:
	if current_decor == null:
		return
		
	var new_hovered_cell = SpatialLookup.get_cell_coords(get_global_mouse_position())
	
	if new_hovered_cell != current_hovered_cell:
		current_hovered_cell = new_hovered_cell
		validate_preview_placement()
		
func validate_preview_placement():
		
	var context = PlacementContext.new()
	context.data = current_decor.data
	context.occupied_cells = current_decor.get_occupied_cells(current_decor.get_anchor_cell)
	context.target_cell = current_decor.get_anchor_cell
		
	PlacementValidator.can_place(context)
	
