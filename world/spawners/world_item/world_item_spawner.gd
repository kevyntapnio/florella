extends Node

@export var world_item_scene: PackedScene

func spawn(stack: ItemStack, position: Vector2):
	world_item_scene = preload("res://world/entities/world_item/world_item.tscn")

	var world_item = world_item_scene.instantiate()
	
	world_item.global_position = position + Vector2(
		randf_range(-4, 4),
		randf_range(-4, 4)
	)
	
	var ysort = get_tree().get_first_node_in_group("ysort_world")
	ysort.add_child(world_item)
	world_item.initialize(stack)
