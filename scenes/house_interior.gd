extends Node2D

@onready var scene_controller = $SceneController

func _ready() -> void:
	GridManager.set_tilemap($FloorTilemap)
	TargetingSystem.set_tilemap($FloorTilemap)

func initialize_scene(data): 
	scene_controller.initialize_scene(data)
