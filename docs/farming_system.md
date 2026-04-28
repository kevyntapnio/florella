FARMING SYSTEM

IMPORTANT:
	- farm_tile and crop_nodes only act as interactable world objects
	- responsible only for visuals
	- data and internal state is tracked by FarmSystem
	- FarmSystem keeps track of serialized data
	- signals for changes -> nodes listen -> updates_visuals if affected coordinates mentioned

CROP SPAWNING
	- Crop is spawned by FarmTile when it receives signal tile_updated
	- if tile_updated, if same tile_coordinate, if "crop" is not null, spawn_crop()
	- Crop is spawned by FarmTile, assigned explicit anchor_cell and occupancy to match FarmTile
	- Crop.position is set to match PlantSpawnPoint within FarmTile
	- Crop is added to ysort_world so that it ysorts with everything within its height_level
	
