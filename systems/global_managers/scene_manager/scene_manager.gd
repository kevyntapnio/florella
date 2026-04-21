extends Node

enum Scenes {
	FARM,
	HOUSE,
}

var scene_paths = {
	Scenes.FARM: "res://scenes/level_farm.tscn",
	Scenes.HOUSE: "res://scenes/house_interior.tscn"
}

var transition_data = {}
	
func request_change_scene(scene_id: int, data: Dictionary):
	change_scene(scene_id, data)
	
func change_scene(scene_id: int, data: Dictionary):
	transition_data = data
	
	await FadeLayer.fade_out()
	
	if not scene_paths.has(scene_id):
		push_error("SceneManager ERROR: scene_id not found")
		return
		
	var path = scene_paths[scene_id]

	var packed_scene = load(path)
	
	var new_scene = packed_scene.instantiate()
	
	var old_scene = get_tree().current_scene
	var root = get_tree().root
	
	root.add_child(new_scene)
	get_tree().current_scene = new_scene
	
	if old_scene:
		old_scene.free()
	
	await get_tree().process_frame
	
	if new_scene.has_method("initialize_scene"):
		new_scene.initialize_scene(transition_data)
	else:
		push_error("SceneManager ERROR: initialize_scene missing in Level's root node")
	
	transition_data = {}
	
	await FadeLayer.fade_in()

func get_transition_data():
	return transition_data
	
func clear_transition_data():
	transition_data = {}
