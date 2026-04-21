extends Node

var pending_spawn_id: String = "default"
var spawn_applied:= false

func _ready():
	
	add_to_group("scene_controller")
	call_deferred("try_apply_spawn")
	
func initialize_scene(data: Dictionary):
	
	if data.has("spawn_id"):
		pending_spawn_id = data["spawn_id"]
	else:
		pending_spawn_id = "default"
	 
	try_apply_spawn()
	
func apply_spawn(player):
	
	var spawn_points = get_tree().get_nodes_in_group("spawn_points")
	
	for spawn in spawn_points:
		if spawn.spawn_id == pending_spawn_id:
			player.global_position = spawn.global_position
			spawn_applied = true
	
	push_warning("SceneController ERROR: spawn_point not found")
	
func try_apply_spawn():
	if spawn_applied:
		return
		
	var player = get_tree().get_first_node_in_group("player")
	
	if player == null:
		return
		
	if pending_spawn_id == "":
		return
		
	apply_spawn(player)
	
