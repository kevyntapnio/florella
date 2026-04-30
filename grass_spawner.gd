extends Node2D

@export var grass_variants: Array[PackedScene] = []
@export var tile_query: Node2D
@export var quantity: int
@export var seed_value: int
@export var min_spacing: int

var rng
var ysort

var placed_positions: Array = []

func _ready() -> void:
	get_rng()
	ysort = get_tree().get_first_node_in_group("ysort_world")
	
func get_rng():
	rng = RandomNumberGenerator.new()
	rng.seed = seed_value 
	
func spawn_grass():

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
			
		var place_chance:= 0.2
		
		if has_nearby_grass(tile):
			place_chance = 0.8
			
		if rng.randf() < place_chance:
			var attempts = rng.randi_range(1, 3)
			
			for i in attempts:
				var pos = get_random_position(tile)
				
				if is_valid_position(pos):
					instantiate_grass(tile, pos)
					quantity -= 1
					placed_positions.append(tile)
					
					if quantity <= 0:
						break
		
func is_valid_position(pos: Vector2) -> bool:
	for placed in placed_positions:
		if placed.distance_to(pos) < min_spacing:
			return false
	return true
	
func has_nearby_grass(tile):
	for placed in placed_positions:
		if placed.distance_to(tile) <= 1:
			return true
	return false
	
func shuffle_tile_list(tile_list):
	
	for i in range(tile_list.size() -1, 0, -1):
		var j = rng.randi_range(0, i)
		
		var temp = tile_list[i]
		tile_list[i] = tile_list[j]
		tile_list[j] = temp
		
	return tile_list
	
func instantiate_grass(tile, pos):
	if grass_variants.is_empty():
		push_warning("GrassSpawner ERROR: Assign tall_grass scene in Editor")
		return
	var scene = grass_variants.pick_random()
	var grass_instance = scene.instantiate()
	
	grass_instance.global_position = pos
	
	var subtype = tile_query.get_tile_info(tile)["subtype"]
	
	if subtype == "cliff_top":
		grass_instance.z_index = 1
	else:
		grass_instance.z_index = 0
		
	ysort.add_child(grass_instance)
	
func get_random_position(tile: Vector2i) -> Vector2: 
	
	var base_pos = GridManager.get_world_position(tile)
	
	var half_tile = GridManager.tile_size / 2
	
	var offset = Vector2(
		rng.randf_range(-half_tile, half_tile),
		rng.randf_range(-half_tile, half_tile)
	)
	
	return base_pos + offset
