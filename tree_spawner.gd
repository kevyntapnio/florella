extends Node2D

@export var tree_scene: PackedScene
@export var tree_data_list: Array[TreeData]
@export var quantity: int
@export var spawn_area: Vector2
@export var seed_value: int
@export var min_spacing: float = 32
@export var max_attempts: int

var placed_positions: Array[Vector2]
var valid = true

func _ready():
	var ysort = get_tree().get_first_node_in_group("ysort_world")
	var rng = RandomNumberGenerator.new()
	rng.seed = seed_value
	
	for i in range(quantity):
		
		var attempts = 0
		
		while attempts < max_attempts:
		
			var x = rng.randf_range(-spawn_area.x, spawn_area.x)
			var y = rng.randf_range(-spawn_area.y, spawn_area.y)
		
			var new_position = Vector2(x, y)
		
			for pos in placed_positions:
				if new_position.distance_to(pos) < min_spacing:
					valid = false
					break
					
			if valid == true:
				var tree_instance = tree_scene.instantiate()
				
				var random_data = tree_data_list[rng.randi_range(0, tree_data_list.size() - 1)]
				tree_instance.tree_data = random_data
				
				ysort.add_child(tree_instance)
				tree_instance.global_position = global_position + new_position
				
				placed_positions.append(new_position)
				break
			
			attempts += 1
		
