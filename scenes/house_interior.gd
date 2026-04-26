extends Node2D

@onready var scene_controller = $SceneController
@onready var tile_query = $WorldTileQuery
@export var scene_id: SceneManager.Scenes

func _ready() -> void:
	SceneManager.set_current_scene(scene_id)
	GridManager.set_tilemap($FloorTilemap)
	TargetingSystem.set_tilemap($FloorTilemap)
	PlacementValidator.set_tile_query(tile_query)
	
	initialize_systems()
	
	spawn_decor()

func initialize_scene(data): 
	scene_controller.initialize_scene(data)
	tile_query.initialize($FloorTilemap)

func initialize_systems():
	DecorSystem.set_tilemap($FloorTilemap, $YSortWorld)
	
func spawn_decor():
	if not DecorSystem.placed_decor.is_empty():
		DecorSystem.spawn_decor()

#func _exit_tree() -> void:
	#GridManager.set_tilemap(null)
	#TargetingSystem.set_tilemap(null)
	#PlacementValidator.set_tilemap(null)
