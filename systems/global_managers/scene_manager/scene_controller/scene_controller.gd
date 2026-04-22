extends Node

var spawn_data: Dictionary = {}
var spawn_applied:= false
var has_pending_spawn:= false

func _ready():
	add_to_group("scene_controller")
	
func initialize_scene(data: Dictionary):
	
	spawn_data = data.get("spawn", {})
	has_pending_spawn = true
	 
	try_apply_spawn()
	
func apply_spawn(player):
	
	var spawn_type = spawn_data.get("type", "anchor")
	
	if spawn_type == "position":
		var p = spawn_data.get("pos", {})
		player.global_position = Vector2(p.get("x", 0), p.get("y", 0))
		return
	
	if spawn_type == "anchor":
		var spawn_id = spawn_data.get("id", "default")
		
		var spawn_points = get_tree().get_nodes_in_group("spawn_points")
	
		for spawn in spawn_points:
			if spawn.spawn_id == spawn_id:
				player.global_position = spawn.global_position
				return
	
	push_warning("Spawn failed: " + str(spawn_data))
	
func try_apply_spawn():
	if spawn_applied:
		return
	
	if not has_pending_spawn:
		return
		
	var player = get_tree().get_first_node_in_group("player")
	
	if player == null:
		call_deferred("try_apply_spawn")
		return
		
	apply_spawn(player)
	spawn_applied = true
	has_pending_spawn = false
