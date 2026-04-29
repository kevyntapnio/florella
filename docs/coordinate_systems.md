COORDINATE SYSTEMS

IMPORTANT: WorldSpace script should be the one source of truth for defining these
	coordinate systems.
		: global_position is used as the authoritative world placement reference 

IMPORTANT: OCCUPANCY RULES 
	- All objects registered to coordinate systems are anchored to bottom-right 
		of the bottom-right cell
		
	- anchor_cell : represents the cell from which occupancy grows from
			: calculated by adding Vector(-1, -1) to origin_cell
	
	- origin_cell : represents the cell returned when node's global_position is normalized
	
	- occupied_tiles / occupied_cells: grow from anchor_cell, calculated from bottom-right,
			and grows upwards and left
					: represents an object's footprint/existence in the World
			
	- interaction_zone : almost always defined as occupied_tiles, but special cases may
		be applied based on use-case
			examples: stacked decor on top of surfaces, a large sprite with a special interactable
				surface, etc.

GridManager
- 32 x 32 grid space
- used by tile_query system
- supports multi-tile occupancy
- supports multiple objects per tile

SpatialLookup
- 16 x 16
- handles decor and spatial_objects
- supports multi-tile occupancy
- supports multiple objects per tile

Integration with InteractionSystem
- both coordinate systems are included into TargetingSystem's target acquisition
