extends Node2D

@export var crop_data: CropData
@export var parent_tile: Node2D
@onready var sprite: Sprite2D = $Sprite2D

var growth_stage: int = 0
var days_in_stage: int = 0
var is_regrowing: bool = false

func _ready():
	print("READY:", self)
	TimeManager.day_passed.connect(on_day_passed)
	
func initialize(data: CropData, parent_tile: Node2D):
	
	crop_data = data
	self.parent_tile = parent_tile
	growth_stage = 0
	days_in_stage = 0
	update_visual()
	
func update_visual():
	var current_stage = get_current_stage()
	sprite.texture = current_stage.texture
	
func get_current_stage():
	return crop_data.stages[growth_stage]
	
func on_day_passed():
	days_in_stage += 1
	
	var current_stage = get_current_stage()
	
	if is_regrowing:
		if days_in_stage >= crop_data.regrow_days:
			growth_stage = crop_data.harvest_stage
			days_in_stage = 0
			update_visual()
	else:
		if days_in_stage >= current_stage.duration:
			if growth_stage < crop_data.stages.size() - 1:
				growth_stage += 1
				days_in_stage = 0
				update_visual()
			
func on_interact(item):
	var current_stage = get_current_stage()
	
	if current_stage.harvestable:
		harvest()
		
func harvest(): 
	var current_stage = get_current_stage()
	var item = current_stage.yield_item
	
	if current_stage.remove_on_harvest:
		destroy_crop()
	else:
		if crop_data.is_regrowable:
			growth_stage = crop_data.regrow_stage
			days_in_stage = 0
			is_regrowing = true
			update_visual()
		else:
			destroy_crop()
			
func destroy_crop():
	parent_tile.clear_crop()
	queue_free()
