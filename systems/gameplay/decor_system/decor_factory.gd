class_name DecorFactory
extends RefCounted

var runtime_scene_map = {
	DecorData.DecorRuntimeBehavior.STATIC: preload("res://test_objects/decor_item/decor_0.tscn"),
	DecorData.DecorRuntimeBehavior.GENERIC_INTERACTIVE: preload("res://test_objects/decor_item/decor_0.tscn"),
	DecorData.DecorRuntimeBehavior.LIGHT_SOURCE: preload("res://test_objects/decor_item/decor_0.tscn"),
	DecorData.DecorRuntimeBehavior.MUSIC_PLAYER: preload("res://test_objects/decor_item/decor_0.tscn")
}

func create_decor(decor_data: DecorData) -> DecorObject:
	var type = decor_data.decor_runtime_behavior
	
	if not runtime_scene_map.has(type):
		push_error("DecorFactory ERROR: decor_runtime_type not loaded into script")
		return null
		
	var scene_ref = runtime_scene_map[type]
	var decor_instance = scene_ref.instantiate()
	decor_instance.initialize(decor_data)
	
	return decor_instance
	
