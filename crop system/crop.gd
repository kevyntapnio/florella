extends Node2D

var growth_stage = 0
var days_in_stage = 0
var crop_data
var is_regrowing = false

var interaction_action = "Harvest"

## Path to TimeManager doesn't exist yet because I haven't set it up
@onready var time_manager = get_tree().root.get_node("Game/TimeManager")

@export var sprite: Sprite2D

func _ready():
	time_manager.day_passed.connect(on_day_passed)

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
	
	if growth_stage == crop_data.harvest_stage and not is_regrowing:
		return
	
	days_in_stage += 1

	if is_regrowing:
		if days_in_stage >= crop_data.regrow_days:
			growth_stage = crop_data.harvest_stage
			days_in_stage = 0
			is_regrowing = false
			update_sprite()
	else:
		var stage_days = crop_data.stage_days
		
		if days_in_stage >= stage_days[growth_stage]:
			if growth_stage < crop_data.harvest_stage:
				growth_stage += 1
				days_in_stage = 0
				update_sprite()
			
func get_interaction_action():
	if growth_stage == crop_data.harvest_stage:
		return interaction_action
	
func interact():
	if growth_stage == crop_data.harvest_stage:
		harvest()

func harvest():
	# InventorySystem.add_item(crop_data.harvest_item)  (later)

	if crop_data.regrow_days > 0:
		growth_stage = crop_data.regrow_stage
		days_in_stage = 0
		is_regrowing = true
		update_sprite()
	else:
		queue_free()
