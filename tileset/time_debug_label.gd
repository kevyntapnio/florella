extends Label


func _ready():
	TimeManager.time_updated.connect(update_time_display)
	
	# Initial sync
	update_time_display(TimeManager.current_hour, TimeManager.current_minute)
	
func update_time_display(hour, minute):
	var time = TimeManager.get_display_time()
	text = "Time: %02d:%02d %s" % [time["hour"], time["minute"], time["am_pm"]]
