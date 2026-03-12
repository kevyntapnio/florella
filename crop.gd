extends Node2D

var growth_stage = 0
var days_in_stage = 0
var crop_data

@export var sprite: Sprite2D

func receive_crop_data(data):
	crop_data = data
	growth_stage = 0
	days_in_stage = 0
	update_sprite()
	
func update_sprite():
	sprite.texture = crop_data.stage_textures[growth_stage]

func on_day_passed():
	if crop_data == null:
		return
		
	days_in_stage += 1
	
	var stage_days = crop_data.stage_days
	var stage_textures = crop_data.stage_textures
	
	if days_in_stage >= stage_days[growth_stage]:
		if growth_stage < stage_textures.size() - 1:
			growth_stage += 1
			days_in_stage = 0
			update_sprite()
