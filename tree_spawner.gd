extends Node2D

@export var tree_scene: PackedScene
@export var tree_data_list: Array[TreeData] = []
@export var tile_query: Node2D
@export var quantity: int
@export var seed_value: int
@export var min_spacing: int

var rng

var placed_positions: Array = []

func _ready() -> void:
	get_rng()
	
func get_rng():
	rng = RandomNumberGenerator.new()
	rng.seed = seed_value 
	
func spawn_trees():

	var tile_list = tile_query.tile_cache.keys()
	var shuffled_list = tile_list.duplicate()
	shuffle_tile_list(shuffled_list)
	
	for tile in shuffled_list:
		var tile_data = tile_query.get_tile_info(tile)
		
		var properties = tile_data["properties"]
		
		if not tile_data["properties"]["spawnable"]:
			continue
		
		if GridManager.is_grid_occupied(tile):
			continue
		
		if not is_position_valid(tile):
			continue
			
		spawn_tree(tile)
		placed_positions.append(tile)
		
		if placed_positions.size() >= quantity:
			break
		
func shuffle_tile_list(tile_list):
	
	for i in range(tile_list.size() -1, 0, -1):
		var j = rng.randi_range(0, i)
		
		var temp = tile_list[i]
		tile_list[i] = tile_list[j]
		tile_list[j] = temp
		
	return tile_list
	
func is_position_valid(new_position):
	for pos in placed_positions:
		var distance = abs(new_position.x - pos.x) + abs(new_position.y - pos.y)
		if distance <= min_spacing:
			return false
	return true
	
func spawn_tree(tile):
	
	var data = get_random_data()
	
	if tree_scene == null:
		print("TreeSpawner ERROR: Assign tree.tscn in Editor")
		return
	
	var tree_instance = tree_scene.instantiate()
	var pos = GridManager.get_world_position(tile)
	
	tree_instance.global_position = pos
	tree_instance.tree_data = data
	
	var subtype = tile_query.get_tile_info(tile)["subtype"]
	
	if subtype == "cliff_top":
		tree_instance.z_index = 1
	else:
		tree_instance.z_index = 0
	
	var ysort = get_tree().get_first_node_in_group("ysort_world")
	ysort.add_child(tree_instance)
	
func get_random_data():
	if tree_data_list.is_empty():
		push_error("TreeSpawner: tree_data_list is empty")
		return null
		
	var index = rng.randi_range(0, tree_data_list.size() - 1)
	var data = tree_data_list[index]
	
	return data
