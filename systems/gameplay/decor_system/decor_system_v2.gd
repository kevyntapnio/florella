extends Node

var build_session: BuildSession
var decor_factory: DecorFactory
var placement_validator: PlacementValidator
var placement_executor: PlacementExecutor

var y_sort: Node

var placed_decor: Dictionary[Vector2i, DecorObject] = {}

func setup(y_sort_ref: Node) -> void:
	decor_factory = DecorFactory.new()
	placement_validator = PlacementValidator.new()
	placement_executor = placement_executor.new()
	
	y_sort = y_sort_ref
	
func initialize_build_mode(data: DecorData) -> void:
	build_session = BuildSession.new()
	add_child(build_session)
	
	build_session.setup(decor_factory, placement_validator, y_sort)
	
	
	
