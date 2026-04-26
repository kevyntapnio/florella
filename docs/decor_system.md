DECOR SYSTEM

## RULES:
	- position and occupancy follows bottom right anchor
	- anchor_cell: used to derive placement and multi-tile occupancy for logic grid
	- visual_cell: used to calculate its world_position relative to visuals
	 
## SURFACE-HANDLING
	- objects that are is_stacked are visually offset
	- is_stacked objects position.y is "glued" to its surface_object's y-level + 1
	- +1 offset ensures that the the stacked_object.y has bias over surface_object.y
	
