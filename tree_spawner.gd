extends Node2D

@export var tree_scene: PackedScene
@export var tree_data_list: Array[TreeData]
@export var quantity: int
@export var spawn_area: Vector2
@export var seed_value: int


func _ready():
	var ysort = get_tree().get_first_node_in_group("ysort_world")
	var rng = RandomNumberGenerator.new()
	rng.seed = seed_value

	for i in range(quantity):
		
		var tree_instance = tree_scene.instantiate()
		
		var x = rng.randf_range(-spawn_area.x, spawn_area.x)
		var y = rng.randf_range(-spawn_area.y, spawn_area.y)
		
		tree_instance.global_position = Vector2(x, y)
		
		print("POSITION", tree_instance.global_position)
		
		var random_data = tree_data_list[rng.randi_range(0, tree_data_list.size() - 1)]
		tree_instance.tree_data = random_data
		
		ysort.add_child(tree_instance)
		
		
