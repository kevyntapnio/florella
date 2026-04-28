extends Node

signal tile_updated(grid_position: Vector2i, data)

var tiles_data: Dictionary = {}

const STATE_PRIORITY = {
	"watered" = 2,
	"tilled" = 1,
}

func _ready() -> void:
	TimeManager.day_passed.connect(_on_day_passed)

func get_tile_data(position):
	if not tiles_data.has(position):
		tiles_data[position] = create_default_tile()
		
	return tiles_data[position]
	
func create_default_tile():
	return {
		"soil": {
			"untilled": true,
			"tilled": false,
			"watered": false
		},
		"crop": null
	}

func debug_signal():
	var data = {
		"soil": {
			"untilled": true,
			"tilled": false,
			"watered": false,
		},
		"crop": null
	}
	var debug_pos = Vector2i(12, 19)
	tile_updated.emit(debug_pos, data)
	
func till_tile(position: Vector2i) -> bool:
	var tile_data = get_tile_data(position)
	
	if tile_data["soil"]["untilled"]:
		tile_data["soil"]["untilled"] = false
		tile_data["soil"]["tilled"] = true
		
	elif tile_data["soil"]["tilled"]:
		if tile_data["crop"] == null:
			tile_data["soil"]["tilled"] = false
			tile_data["soil"]["untilled"] = true
	
	tile_updated.emit(position, tile_data)
	
	return true
	
func water(position: Vector2i) -> bool:
	var tile_data = get_tile_data(position)
	
	if tile_data["soil"]["tilled"]:
		tile_data["soil"]["watered"] = true
		
	tile_updated.emit(position, tile_data)
	
	return true

func plant(position: Vector2i, crop_data: CropData) -> bool:
	## This function returns a bool for remove_item validation
	
	var tile_data = get_tile_data(position)
	
	if tile_data["crop"] != null:
		return false
		
	if not is_tilled(position):
		return false
	
	tile_data["crop"] = {
		"crop_id": crop_data.id,
		"resource": crop_data,
		"growth_stage": 0,
		"days_in_stage": 0,
		"is_regrowing": false
	}
	
	tile_updated.emit(position, tile_data)
	
	return true
	
func is_tilled(position: Vector2i) -> bool:
	var tile_data = get_tile_data(position)
	
	return tile_data["soil"]["tilled"] or tile_data["soil"]["watered"]
	
func is_watered(position: Vector2i):
	var tile_data = get_tile_data(position)
	
	return tile_data["soil"]["watered"]
	
func _on_day_passed() -> void:
	
	for pos in tiles_data:
		
		var tile = tiles_data[pos]
		var crop = tile.get("crop")
		
		var watered = tile["soil"]["watered"]
		
		tile["soil"]["watered"] = false
		
		if watered and crop:
			
			var crop_res = crop["resource"]
			
			if crop_res == null: 
				push_error("FarmSystem ERROR: crop resource not found in tile_data")
				continue
				
			var growth_stage = crop["growth_stage"]
			var current_stage = crop_res.stages[growth_stage]
			
			var can_advance = growth_stage < crop_res.stages.size() - 1
			
			if can_advance or crop["is_regrowing"]: 
				crop["days_in_stage"] += 1
			
			var days = crop["days_in_stage"]
			
			if crop["is_regrowing"]:
				if days >= crop_res.regrow_days:
					crop["growth_stage"] = crop_res.regrow_target_stage
					crop["days_in_stage"] = 0
			else:
				if days >= current_stage.duration:
					if can_advance:
						crop["growth_stage"] += 1
						crop["days_in_stage"] = 0
						
		tile_updated.emit(pos, tile)
				
				
func harvest(position: Vector2i) -> bool:

	var tile_data = get_tile_data(position)
	
	var crop = tile_data.get("crop")
	
	if crop == null:
		return false
		
	var growth_stage = crop["growth_stage"]
	var crop_res = crop["resource"]
	
	if crop_res == null: 
		push_error("FarmSystem ERROR: crop resource not found in tile_data")
		return false
		
	var current_stage = crop_res.stages[growth_stage]
	
	if not current_stage.harvestable:
		return false
		
	## check if current_stage (final seed_pod stage) forces crop destruction
	## this is added because seed_pod stage overrides is_regrowable and is always destroyed when harvested
	
	if current_stage.remove_on_harvest:
		tile_data["crop"] = null
		tile_updated.emit(position, tile_data)
	
	## check if crop is regrowable
	elif crop_res.is_regrowable:
		crop["growth_stage"] = crop_res.regrow_stage
		crop["days_in_stage"] = 0
		crop["is_regrowing"] = true
		
	## fallback/safety net
	else:
		tile_data["crop"] = null
	
	spawn_yield_stack(current_stage.yield_item, current_stage.yield_amount, position)
		
	tile_updated.emit(position, tile_data)
	
	return true
		
func spawn_yield_stack(item: ItemData, quantity: int, position: Vector2i) -> void:
	
	var stack = ItemStack.new()
	
	stack.item_data = item
	stack.quantity = quantity
	
	var pos = GridManager.get_world_position(position)
	
	WorldItemSpawner.spawn(stack, pos)
	
func is_harvestable(position: Vector2i) -> bool:
	var tile_data = get_tile_data(position)
	var crop = tile_data.get("crop")
	
	if crop == null:
		return false
		
	var growth_stage = crop["growth_stage"]
	
	var current_stage = crop["resource"].stages[growth_stage]
	
	return current_stage.harvestable
	
func get_save_data() -> Dictionary:
	
	var save_data:= {}
	
	for pos in tiles_data:
		var tile = tiles_data[pos]
		
		var tile_copy = tile.duplicate(true)
		
		var crop = tile_copy.get("crop")
		
		if crop != null:
			crop.erase("resource")
			
		var key = str(pos.x) + "," + str(pos.y)
		save_data[key] = tile_copy
		
	return save_data
	
func load_from_data(save_data: Dictionary):
	
	tiles_data.clear()
	
	for key in save_data:
		
		var parts = key.split(",")
		var pos = Vector2i(parts[0].to_int(), parts[1].to_int())
		
		var tile = save_data[key]
		var crop = tile.get("crop")
		
		if crop != null:
			var crop_id = crop["crop_id"]
			var resource = ItemDatabase.get_crop(crop_id)
			
			if resource == null:
				push_error("FarmSystem ERROR: crop resource not found in ItemDatabase")
			else:
				crop["resource"] = resource
		
		tiles_data[pos] = tile
		
		tile_updated.emit(pos, tile)

func resolve_soil_state(soil: Dictionary):
	
	var best_state = null
	var best_priority = -1
	
	for state in soil:
		if not soil[state]:
			continue
			
		var priority = STATE_PRIORITY.get(state, 0)
		
		if priority > best_priority:
			best_priority = priority
			best_state = state
	
	return best_state
