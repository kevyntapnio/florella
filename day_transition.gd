extends CanvasLayer

@onready var color_rect = $ColorRect

var morning_color = Color(1.0, 0.755, 0.36, 0.192)
var afternoon_color = Color(1.0, 1.0, 1.0, 0.0)
var evening_color = Color(1.0, 0.5, 0.23, 0.267)
var night_color = Color(0.156, 0.117, 0.45, 0.506)
var current_tween: Tween = null

func _ready():
	
	TimeManager.time_updated.connect(_on_time_updated)
	color_rect.color = get_color_for_hour(TimeManager.current_hour)
	update_time_of_day(TimeManager.current_hour)
	
func _on_time_updated(hour, minute):
	update_time_of_day(hour)
	
func update_time_of_day(hour):
	var target_color = get_color_for_hour(hour)
	apply_color(target_color)

func get_color_for_hour(hour):
	if hour >= 6 and hour < 12:
		return morning_color
	elif hour >= 12 and hour < 16:
		return afternoon_color
	elif hour >=16 and hour < 19:
		return evening_color
	else:
		return night_color
	
func apply_color(target_color: Color):
	if current_tween:
		current_tween.kill()
		
	current_tween = create_tween()
	current_tween.tween_property(color_rect, "color", target_color, 1.5)
