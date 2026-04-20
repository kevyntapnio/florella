extends Node

signal day_passed
signal time_updated(hour, minute)
signal day_ended
signal day_updated(current_day, current_year)

var current_day: int = 1
var current_year: int = 1
var pause_sources: Array = []
var current_hour = 6
var current_minute = 0

var time_accumulator: float = 0.0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
func advance_day():
	if is_paused():
		return
	
	print("ADVANCE DAY CALLED")	
	current_day += 1
	reset_day_timer()
	
	emit_signal("day_ended")
	emit_signal("day_passed")
	day_updated.emit(current_day, current_year)
	time_updated.emit(current_hour, current_minute)

func _process(delta):
	if is_paused():
		return
		
	time_accumulator += delta
	
	if time_accumulator >=0.78:
		time_accumulator = 0.0
		advance_time()
	
func advance_time():
	
	current_minute += 10
	
	if current_minute >= 60:
		current_minute -= 60
		current_hour += 1
		
		if current_hour >= 24:
			current_hour = 0
	emit_signal("time_updated", current_hour, current_minute)
		
	check_day_end()

func pause_time(source):
	if source not in pause_sources:
		pause_sources.append(source)
		update_pause_state()
		
func resume_time(source):
	if source not in pause_sources:
		return
	pause_sources.erase(source)
	update_pause_state()
	
func is_paused() -> bool:
	return pause_sources.size() > 0
	
func check_day_end():
	if current_hour == 2 and current_minute == 0:
		advance_day()
		
func reset_day_timer():
	current_hour = 6
	current_minute = 0
	
func get_display_time():
	var display_hour
	var am_pm
	
	if current_hour == 0: # midnight
		display_hour = 12
		am_pm = "AM"
	elif current_hour < 12: # 1–11
		display_hour = current_hour
		am_pm = "AM"
	elif current_hour == 12: # noon
		display_hour = 12
		am_pm = "PM"
	else: # 13–23
		display_hour = current_hour - 12
		am_pm = "PM"
	
	return {
		"hour": display_hour,
		"minute": current_minute,
		"am_pm": am_pm
	}
		
func update_pause_state():
	get_tree().paused = is_paused()
	
func get_current_hour():
	return current_hour
	
func get_current_day():
	## Year temporarily set to 1
	var day = {
		"day": current_day,
		"year": 1
	}
	return day
	
func get_save_data() -> Dictionary:
	var save_data = {
		"current_day": current_day,
		"current_hour": current_hour,
		"current_minute": current_minute
	}
	return save_data
	
func load_from_data(data: Dictionary):
	
	current_day = data.get("current_day", 1)
	current_hour = data.get("current_hour", 6)
	current_minute = data.get("current_minute", 0)
	
	time_updated.emit(current_hour, current_minute)
	day_updated.emit(current_day, current_year)
