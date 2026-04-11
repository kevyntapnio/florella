extends GridObject

@onready var wind_shader = preload("res://shaders/wind_sway.gdshader")

@export var grass_textures: Array[Texture2D]

@export var blocks_tile:= false

static var last_sfx_time:= 0.0
static var sfx_cooldown:= 0.05
var rng:= RandomNumberGenerator.new()
var sprite 
var blades = []

func _ready(): 	
	get_blades()
	apply_shader()
	
func apply_shader():
	for blade in blades:
		
		var mat = ShaderMaterial.new()
		mat.shader = wind_shader
		
		mat.set_shader_parameter("world_y", global_position.y)
		mat.set_shader_parameter("blade_offset", rng.randf_range(0.0, 3.0))
		
		blade.material = mat
	
func get_blades():
	
	get_children()
	
	for child in get_children():
		if child is Sprite2D:
			blades.append(child)
			
func react():
	for blade in blades:
		## -- Remove existing tween on this blade -- ##
		if blade.has_meta("sway_tween"): 
			var old_tween = blade.get_meta("sway_tween")
			if old_tween and old_tween.is_running():
				old_tween.kill()
		
		## -- Add new tween -- ##
		var tween = create_tween()
		set_meta("sway_tween", tween)
		
		var direction = [-1, 1].pick_random()
		var strength = randf_range(0.3, 0.6) * direction
			
		tween.tween_property(blade, "rotation", strength, 0.1)\
			.set_trans(Tween.TRANS_SINE)\
			.set_ease(Tween.EASE_OUT)
				
		tween.tween_property(blade, "rotation", 0.0, 0.3)\
			.set_trans(Tween.TRANS_SINE)\
			.set_ease(Tween.EASE_IN)
	
	play_sfx()
	
func play_sfx():
	var sfx = $SwaySFX
	var current_time = Time.get_ticks_msec() / 1000.0
	
	if current_time - last_sfx_time > sfx_cooldown:
		last_sfx_time = current_time
		
		sfx.volume_db = -10.0

		sfx.pitch_scale = randf_range(0.85, 1.15)
		sfx.play()
		
		var tween = create_tween()
		var duration = 0.7
		
		tween.tween_interval(duration * 0.5)
		
		tween.tween_property(sfx, "volume_db", -80.0, duration * 0.5)
		
		tween.finished.connect(sfx.stop)
		
