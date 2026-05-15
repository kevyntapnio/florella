extends Node2D

@onready var scene_controller = $SceneController
@onready var tile_query = $WorldTileQuery
@onready var interaction_system = $InteractionSystem
@onready var targeting_system = $TargetingSystem
@onready var ysort_world = $YSortWorld

@export var player: Node2D
@export var scene_id: SceneManager.Scenes

func _ready() -> void:
	SceneManager.set_current_scene(scene_id)
	GridManager.setup()
	tile_query.initialize($FloorTilemap)
	
	initialize_systems()
	setup()
	
	spawn_decor()
	
func setup():
	interaction_system.setup(targeting_system)
	targeting_system.setup()
	player.setup(interaction_system, targeting_system)

func initialize_scene(data): 
	scene_controller.initialize_scene(data)

func initialize_systems():
	DecorSystem.setup(ysort_world, tile_query)
	
func spawn_decor():
	if not DecorSystem.placed_decor.is_empty():
		DecorSystem.spawn_decor()


#func _exit_tree() -> void:
	#GridManager.set_tilemap(null)
	#TargetingSystem.set_tilemap(null)
	#PlacementValidator.set_tilemap(null)
