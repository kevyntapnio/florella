extends CanvasModulate

@onready var color_rect = $ColorRect

var morning_color = Color(1.0, 0.755, 0.36, 0.192)
var afternoon_color = Color(1.0, 1.0, 1.0, 0.0)
var evening_color = Color(1.0, 0.5, 0.23, 0.267)
var night_color = Color(0.156, 0.117, 0.45, 0.506)
var current_tween: Tween = null

func _ready():
	
	TimeManager.time_updated.connect(_on_time_updated)
	color_rect.color = get_color_for_hour(TimeManager.current_hour)
	update_time_of_day(TimeManager.current_hour, TimeManager.current_minute)
	
func _on_time_updated(hour, minute):
	update_time_of_day(hour, minute)
	
func update_time_of_day(hour, minute):
	var time_float = hour + minute / 60.0
	var target_color = get_color_for_hour(time_float)
	
	apply_color(target_color)

func get_color_for_hour(time_float):
	if time_float >= 6 and time_float < 12:
		var t = (time_float - 6) / 6
		return morning_color.lerp(afternoon_color, t)
	elif time_float >= 12 and time_float < 17.5:
		var t = (time_float - 12) / 5.5
		return afternoon_color.lerp(evening_color, t)
	elif time_float >= 17.5 and time_float < 18.5:
		var t = (time_float - 17.5) / 1
		return evening_color.lerp(night_color, t)
	else:
		return night_color
	
func apply_color(target_color: Color):
	if current_tween:
		current_tween.kill()
		
	current_tween = create_tween()
	current_tween.tween_property(color_rect, "color", target_color, 1.5)\
		.set_trans(Tween.TRANS_SINE) \
		.set_ease(Tween.EASE_IN_OUT)
		
