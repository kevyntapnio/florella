extends Node2D

@export var targeting_system: Node2D
@export var grid_manager: Node2D

# Can this be an autoload?
@export var inventory_system: Node2D

var nearby_interactables: Array = []
var focused_interactable = null

func _process(delta: float) -> void:
	update_focused_interactable()
	
func register_interactable(interactable):
	nearby_interactables.append(interactable)

func unregister_interactable(interactable):
	nearby_interactables.erase(interactable)
	
func get_closest_interactable():
	
	if nearby_interactables.is_empty():
		return null
	if targeting_system.player_global_position == null:
		return null
		
	var closest_object = null
	var smallest_distance = INF
	
	for interactable in nearby_interactables:
		var distance = targeting_system.player_global_position.distance_to(interactable.global_position)
		
		
		if distance < smallest_distance:
			smallest_distance = distance
			closest_object = interactable
	
	return closest_object
	
func update_focused_interactable():
	
	var closest_interactable = get_closest_interactable()
	
	if closest_interactable != focused_interactable:
		
		if focused_interactable:
			focused_interactable.on_focus_exited()
		
		focused_interactable = closest_interactable
		
		if focused_interactable:
			focused_interactable.on_focus_entered()
			
func handle_interact(selected_item):
	
	var player_coords = targeting_system.player_tile_coords
	var interactable = get_closest_interactable()

	if interactable != null:
		interactable.interact(selected_item, player_coords)
		return
	
	var target_coords = targeting_system.current_target_coords
	var target_tile = grid_manager.get_grid_object(target_coords)
	
	var context = {"player": player_coords, "target": target_coords}
	
	if target_tile != null:
		target_tile.interact(selected_item, context)
		return
				
