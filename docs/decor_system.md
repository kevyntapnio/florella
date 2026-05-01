DECOR SYSTEM

## RULES:
	- position and occupancy follows bottom right anchor
	- anchor_cell: used to derive placement and multi-tile occupancy for logic grid
	- origin_cell: used to calculate its world_position relative to visuals
	- for surface_stacking: decor_data.has_surface means item can be stacked on top of it
	
FLOW:
	- Player creates BuildSession.new() and calls initialize_build_mode(item_data: DecorData)
	- BuildSession: becomes the central controller for the placement mechanics: preview, temporary
		state for object while not is_placed
	- DecorFactory: responsible for instantiating the correct PackedScenes based on DecorData.DecorRuntimeBehavior
	- PlacementValidator: used by BuildSession per process frame for preview evaluation to update
		visuals accordingly (invalid? red modulate. valid? ghost modulate. on top of buildable surface?
		apply visual y offset to sprite display)
	- DecorSystem: owns placed_decor cache. responsible for persistent state and is final authorative layer
		for finalizing placement consequences and bookkeeping information. also has spawn_decor(), called by Level's
		setup 
		
DATA STRUCTURE:
	- DecorData: holds general data that the decor needs to exist logically and visually in the world
	- DecorVariant: holds specific data for each decor variant, wherein "variant" means rotation (left, right,
		up, down)
	- DecorObject base class will be inherited by subclasses based on runtime behavior (can be interacted
		with apart from removal logic)
	- Makes use of the following RefCounted resources: PlacementContext, PlacementResult, PlacementRequest

	 
## SURFACE-HANDLING
	- objects that are is_stacked are visually offset
	- is_stacked objects position.y is "glued" to its surface_object's y-level + 1
	- position.y +1 offset ensures that the the stacked_object.y has bias over surface_object.y
	- DEPTH handling: inside PlacementValidator, it calculates offset value based on on
		depth index of buildable surface
			- surface_height + (surface_height * depth)
			- this returns default height or calculated offset based on how far the new decor is
			from the surface_object
			- conceptually: if plant is hovered over front row grid closest to camera, depth_index 
			is 0. returns default height. if plant is hovered over 2nd row of the grid, depth_index is
			1. return height + height.
			- the offset is then applied to object's visuals by "gluing" the new_decor's y-level to
			be precisely surface_object.y_level + 1.0 
			
DESIGN DECISIONS AND CONSTRAINTS:
	- surface_objects must be simplified and must follow surface_area = object_size / occupancy_footprint
	- "loose" placement rules for stacking. even if only 1 tile overlaps with surface, the
		object may be placed on top of it (even if most of its visuals are still hanging
		over the edge)
	- rugs are also included in surface_objects but may or may not have height offset
	- for assets: try to design everything loosely following the 16px grid so that no highly special logic
		is needed for spatial systems to keep up with
		
DEPENDENCIES:
	- SpatialLookup system --- expected coupling for validation
	- GridManager --- expected coupling for validation
	- YSortWorld --- expected coupling for instantiation into world
	- Player --- expected coupling for input (to refine later when Player refactor for state machine is added)
