extends GridObject

@export var tree_data: TreeData

@onready var sprite = $Sprite2D
@onready var collision = $CollisionShape2D

@export var target_alpha: float = 0.3
@export var fadeout_duration = 0.12
@export var fadein_duration = 0.16

var is_occluded = false

func _ready():
	if tree_data:
		apply_tree_data()
	else:
		print("TREE ERROR: TreeData not found")
		
func apply_tree_data():
	
		sprite.texture = tree_data.texture
		
		var shape = RectangleShape2D.new()
		shape.size = tree_data.collision_size
		
		collision.shape = shape
		collision.position = tree_data.collision_offset
		
func set_occlusion():
	
	if is_occluded:
		return
		
	if sprite.has_meta("occlusion_tween"): 
		var old_tween = sprite.get_meta("occlusion_tween")
		if old_tween and old_tween.is_running():
			old_tween.kill()
			
	## -- Add new tween -- ##
	var tween = create_tween()
	set_meta("occlusion_tween", tween)
		
	tween.tween_property(sprite, "modulate:a", target_alpha, fadeout_duration)
	is_occluded = true
	
func remove_occlusion():
	if not is_occluded:
		return
		
	var default = 1.0
	
	if is_occluded:
		if sprite.has_meta("occlusion_tween"): 
			var old_tween = sprite.get_meta("occlusion_tween")
			if old_tween and old_tween.is_running():
				old_tween.kill()
				
		## -- Add new tween -- ##
		var tween = create_tween()
		set_meta("occlusion_tween", tween)
			
		tween.tween_property(sprite, "modulate:a", default, fadein_duration)
			
		is_occluded = false
	
