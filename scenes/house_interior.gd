extends Node2D

@onready var scene_controller = $SceneController
@export var scene_id: SceneManager.Scenes

func _ready() -> void:
	SceneManager.set_current_scene(scene_id)
	GridManager.set_tilemap($FloorTilemap)
	TargetingSystem.set_tilemap($FloorTilemap)
	
	initialize_systems()
	
	await initialize_systems()
	spawn_decor()

func initialize_scene(data): 
	scene_controller.initialize_scene(data)

func initialize_systems():
	DecorSystem.set_tilemap($FloorTilemap, $YSortWorld)
	
func spawn_decor():
	if not DecorSystem.placed_decor.is_empty():
		DecorSystem.spawn_decor()
