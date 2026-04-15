extends GridObject

@onready var light = $PointLight2D

const INTERACT_PRIORITY = 10

var day_brightness: float = 0.35
var night_brightness: float = 0.9
var flicker_time:= 0.0
var base_energy: float = 0.0

func _ready() -> void:
	light.enabled = false
	TimeManager.time_updated.connect(on_time_updated)
	
func _process(delta: float) -> void:
	flicker_time += delta
	
	var flicker = sin(flicker_time * 6.0) * 0.05
	
	light.energy = base_energy + flicker
	
func on_time_updated(hour, minute):
	check_brightness(hour)
	
func check_brightness(hour):
	if hour >= 18 or hour <= 2:
		base_energy = night_brightness
	else: 
		base_energy = day_brightness

func interact(item, context):
	var hour = TimeManager.current_hour
	
	check_brightness(hour)
	light.energy = base_energy
	
	if light.enabled == false:
		light.enabled = true
		
	else:
		light.enabled = false

func set_targeted(is_targeted: bool):

	if is_targeted:
		modulate = Color(1.2, 1.2, 1.2)
	else:
		modulate = Color(1, 1, 1)
	
func get_interaction_score(context):
	return INTERACT_PRIORITY
