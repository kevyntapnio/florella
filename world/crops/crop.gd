extends GridObject

@onready var sprite: Sprite2D = $Sprite2D
@export var harvest_sfx: AudioStream

const INTERACT_PRIORITY = 10

	
func update_visual(crop_state: Dictionary) -> void:
	
	var crop_id = crop_state["crop_id"]
	var resource = crop_state["resource"]
	
	if resource == null:
		push_error("Crop ERROR: crop_data resource missing in crop_state")
		return
		
	var stage = crop_state["growth_stage"]
	
	if stage >= resource.stages.size():
		push_error("Crop ERROR: Invalid growth stage")
		return
		
	sprite.texture = resource.stages[stage].texture
	
func get_interaction_score(context) -> int:
	## NOTE: this function currently receives null only
	# but may change later if targeting_system ever starts using passive_context
	# leaving this context untyped for now
	
	if FarmSystem.is_harvestable(anchor_cell):
		return INTERACT_PRIORITY
		
	return 0
			
func interact(request: InteractionRequest) -> bool:
	
	if FarmSystem.harvest(anchor_cell):
		
		play_harvest_sfx()
		
		var tween = play_harvest_animation()
		await tween.finished
		
		return true
	return false

func can_accept_item(item_data: ItemData) -> bool:
	## NOTE: When harvest tool is added, this function must be edited
	## item_data == null means no item is selected/empty hand interaction
	
	return true
	
func is_currently_interactable() -> bool:
	return FarmSystem.is_harvestable(anchor_cell)
		
func _on_sway_area_body_entered(body: Node2D) -> void:
	## Old logic; will be cleaned up later when centralized feedback system is added
	var data = FarmSystem.get_tile_data(anchor_cell)
	var crop = data.get("crop")
	
	if crop == null:
		return
		
	if data["crop"]["growth_stage"] == 0:
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
		
func play_harvest_sfx() -> void:
	## old logic. will also remove and integrate into existing SoundManager soon
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
	
func set_targeted(is_targeted: bool) -> void:
	if is_targeted and FarmSystem.is_harvestable(anchor_cell):
		modulate = Color(1.3, 1.3, 1.3)
	else:
		modulate = Color(1, 1, 1)
		
func is_focusable() -> bool:
	### NOTE: old logic, remove after successful migration
	return true

func debug_rect():
	for tile in occupied_tiles:
		var rect = ColorRect.new()
		add_child(rect)
		rect.size = Vector2i(32, 32)
		rect.modulate = Color(0.832, 0.0, 0.582, 0.3)
		rect.global_position = GridManager.get_world_position(anchor_cell)
		
	pass
