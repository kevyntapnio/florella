extends Node2D

@onready var scene_controller = $SceneController

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GridManager.set_tilemap($World/GroundTileMap)
	TargetingSystem.set_tilemap($World/GroundTileMap)
	
	FarmVisual.tilled_layer = $World/FarmLogic/FarmVisuals/TilledLayer
	FarmVisual.watered_layer = $World/FarmLogic/FarmVisuals/WateredLayer
	
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

	
func initialize_scene(data): 
	scene_controller.initialize_scene(data)
