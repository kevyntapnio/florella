extends GridObject

@export var crop_data: CropData
@export var parent_tile: Node2D
@onready var sprite: Sprite2D = $Sprite2D
@export var harvest_sfx: AudioStream
@export var world_item_scene: PackedScene
@onready var drop_point = $DropPoint

var growth_stage: int = 0
var days_in_stage: int = 0
var is_regrowing: bool = false

const INTERACT_PRIORITY = 10

func _ready():
	super()
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
	if parent_tile.is_watered():
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
					
func get_interaction_score(context):
	var current_stage = get_current_stage()
	if current_stage.remove_on_harvest or growth_stage == crop_data.harvest_stage:
		return INTERACT_PRIORITY
	return 0
			
func interact(item, context) -> bool:
	var current_stage = get_current_stage()
	
	if current_stage.harvestable:
		harvest()
		return true
	
	return false
		
func harvest(): 
	play_harvest_sfx()
	var tween = play_harvest_animation()
	await tween.finished
	
	var current_stage = get_current_stage()
	var item_data = current_stage.yield_item
	
	if item_data == null:
		return
		
	var id = item_data.id
	var amount = current_stage.yield_amount
	
	if item_data != null:
		spawn_world_item(id, amount)
	
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

func _on_sway_area_body_entered(body: Node2D) -> void:
	if growth_stage == 0:
		return
		
	if body.is_in_group("player"):
		var tween = create_tween()
		var direction = [-1, 1].pick_random()
		var strength = randf_range(0.15, 0.25) * direction
		
		tween.tween_property(self, "rotation", strength, 0.1)\
			.set_trans(Tween.TRANS_SINE)\
			.set_ease(Tween.EASE_OUT)
			
		tween.tween_property(self, "rotation", 0.0, 0.3)\
			.set_trans(Tween.TRANS_SINE)\
			.set_ease(Tween.EASE_IN)

		$SwaySFX.pitch_scale = randf_range(0.85, 1.15)
		$SwaySFX.play()
		
func play_harvest_sfx():
	var sfx = AudioStreamPlayer.new()
	get_tree().current_scene.add_child(sfx)

	sfx.stream = preload("res://assets/audio/sfx/pop.mp3")
	sfx.pitch_scale = randf_range(0.9, 1.15)
	sfx.volume_db = -15
	sfx.play()

	sfx.finished.connect(sfx.queue_free)
	
func play_harvest_animation():
	var tween = create_tween()

	tween.tween_property(self, "scale", Vector2(1.2, 0.8), 0.08) \
		.set_trans(Tween.TRANS_SINE) \
		.set_ease(Tween.EASE_OUT)
	
	tween.tween_property(self, "scale", Vector2(0.9, 1.2), 0.08) \
		.set_trans(Tween.TRANS_SINE) \
		.set_ease(Tween.EASE_IN)
		
	tween.tween_property(self, "scale", Vector2(1, 1), 0.05) 
	
	return tween
	
func spawn_world_item(id, amount):
	var ysort = get_tree().get_first_node_in_group("ysort_world")
	var item_instance = world_item_scene.instantiate()
	
	item_instance.global_position = drop_point.global_position + Vector2(
		randf_range(-4, 4),
		randf_range(-4, 4)
	)
	ysort.add_child(item_instance)
	item_instance.initialize(id, amount)
	
	
