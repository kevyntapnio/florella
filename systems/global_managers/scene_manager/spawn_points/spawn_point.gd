extends Node

@export var spawn_id: String

var spawn_points = []

func _ready() -> void:
	add_to_group("spawn_points")
	
