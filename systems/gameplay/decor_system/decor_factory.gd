class_name DecorFactory
extends RefCounted

var runtime_scene_map = {
	DecorData.DecorRuntimeBehavior.STATIC: preload(""),
	DecorData.DecorRuntimeBehavior.GENERIC_INTERACTIVE: preload(""),
	DecorData.DecorRuntimeBehavior.LIGHT_SOURCE: preload(""),
	DecorData.DecorRuntimeBehavior.MUSIC_PLAYER: preload("")
}

func create_decor(decor_data: DecorData) -> DecorObject:
	var type = decor_data.decor_runtime_type
	
	if not runtime_scene_map.has(type):
		push_error("DecorFactory ERROR: decor_runtime_type not loaded into script")
		return null
		
	var scene_ref = runtime_scene_map[decor_data.decor_runtime_type]	
	var decor_instance = scene_ref.instantiate()
	decor_instance.data = decor_data
	
	return decor_instance
	
