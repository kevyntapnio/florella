extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GridManager.set_tilemap($World/GroundTileMap)
	TargetingSystem.set_tilemap($World/GroundTileMap)
	
	FarmVisual.tilled_layer = $World/FarmLogic/FarmVisuals/TilledLayer
	FarmVisual.watered_layer = $World/FarmLogic/FarmVisuals/WateredLayer
	
	InventorySystem.add_item("basic_hoe", 1)
	InventorySystem.add_item("basic_watering_can", 1)
	InventorySystem.add_item("tulip", 1)

	var world_tile_query = $Systems/WorldTileQuery
	
	world_tile_query.set_terrain_layers()
	
	var collision_builder = $Systems/CollisionBuilder
	if collision_builder.is_inside_tree():
		collision_builder.set_colliders()
	
	await get_tree().process_frame
	
	if $Spawners/TreeSpawner.is_inside_tree():
		$Spawners/TreeSpawner.spawn_trees()
		
	#if $Spawners/GrassSpawner.is_inside_tree():
		#$Spawners/GrassSpawner.spawn_grass()

	if $World/GrassDetailMap.is_inside_tree():
		$World/GrassDetailMap.add_grass_tile_variants()

	PlayerGlobalStats.add_to_wallet(5000)
