extends Node2D

@export var tree_instance: PackedScene
@export var tree_data_list: Array = []
@export var quantity = 15
@export var spawn_area: Vector2

var tree

func _ready():
	var ysort = get_tree().get_first_node_in_group("ysort_world")
	
	for i in range(quantity):
		
		tree = tree.instantiate()
		
		var x = randf_range(-spawn_area.x, spawn_area.y)
		var y = randf_range(-spawn_area.x, spawn_area.y)
		tree.global_position = global_position + Vector2(x, y)
		
		var random_data = tree_data_list.pick_random()
		tree.tree_data = random_data
		
		ysort.add_child(tree)
		
		
		
	
