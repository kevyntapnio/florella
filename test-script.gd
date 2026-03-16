
	
	if Input.is_action_just_pressed("use_item"):
		if current_hovered_tile == null:
			return
		
		var selected_item = InventorySystem.get_selected_item()
		
		if selected_item == null:
			return
			
		selected_item.use(current_hovered_tile)


var tile_in_front
var current_hovered_coords
var current_target_coords

func get_tile_in_front():
	
	## Can be compressed into one line, kept for readability while learning
	var local_pos = tilemap.to_local(global_position)
	var grid_coords = tilemap.local_to_map(local_pos)
	
	var tile_in_front = grid_coords + facing_direction
	
	return tile_in_front


## removed from player script, changed to grid targeting
func update_current_target():

	if current_hovered_coords:
		current_target_coords = current_hovered_coords
	else:
		current_target_coords = tile_in_front

func _on_tile_detector_area_entered(area: Area2D) -> void:

	var farm_tile = area.get_parent()
	nearby_tiles.append(farm_tile)
	
func _on_tile_detector_area_exited(area: Area2D) -> void:
	
	var farm_tile = area.get_parent()
	nearby_tiles.erase(farm_tile)
	
	find_closest_tile()
