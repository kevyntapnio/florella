extends PointLight2D

func _ready() -> void:
	print("light ready")
	enabled = false
	TimeManager.time_updated.connect(on_time_updated)
	
func on_time_updated(hour, minute):
	print("signal_received")
	if hour >= 19:
		enabled = true
	elif hour <= 2:
		enabled = true
	else:
		enabled = false
