extends Node

signal tile_updated(grid_position: Vector2i, data)

var tiles_data: Dictionary = {}

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
	
func till_tile(position: Vector2i):
	var tile_data = get_tile_data(position)
	
	if tile_data["soil"]["untilled"]:
		tile_data["soil"]["untilled"] = false
		tile_data["soil"]["tilled"] = true
		
	elif tile_data["soil"]["tilled"]:
		if tile_data["crop"] == null:
			tile_data["soil"]["tilled"] = false
			tile_data["soil"]["untilled"] = true
	
	tile_updated.emit(position, tile_data)
	
func water(position: Vector2i):
	var tile_data = get_tile_data(position)
	
	if tile_data["soil"]["tilled"]:
		tile_data["soil"]["watered"] = true
		
	tile_updated.emit(position, tile_data)

func plant(position: Vector2i, crop_data: CropData) -> bool:
	## This function returns a bool for remove_item validation inside Seed
	
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
	
func is_tilled(position: Vector2i):
	var tile_data = get_tile_data(position)
	
	return tile_data["soil"]["tilled"] or tile_data["soil"]["watered"]
	
func is_watered(position: Vector2i):
	var tile_data = get_tile_data(position)
	
	return tile_data["soil"]["watered"]
	
func _on_day_passed():
	
	for pos in tiles_data:
		var tile = tiles_data[pos]
		var crop = tile.get("crop")
		
		if not crop or not tile["soil"]["watered"]:
			continue
			
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
				
				tile["soil"]["watered"] = false
				
				tile_updated.emit(pos, tiles_data[pos])
		else:
			if days >= current_stage.duration:
				if growth_stage < crop_res.stages.size() - 1:
					crop["growth_stage"] += 1
					crop["days_in_stage"] = 0
					
					tile["soil"]["watered"] = false
					
					tile_updated.emit(pos, tiles_data[pos])
				
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
		
func spawn_yield_stack(item, quantity, position):
	
	var stack = ItemStack.new()
	
	stack.item_data = item
	stack.quantity = quantity
	
	var pos = GridManager.get_world_position(position)
	
	WorldItemSpawner.spawn(stack, pos)
