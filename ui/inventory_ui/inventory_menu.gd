extends MenuBase

@export var current_day_label: Label
@export var current_gold_label: Label
@export var exit_button: TextureButton

func _ready():
	layer = 15
	visible = false
	
	TimeManager.day_passed.connect(on_day_passed)
	PlayerGlobalStats.wallet_changed.connect(on_wallet_changed)
	
	update_day_display()
	
func toggle():
	if is_open:
		close()
	else:
		open()
		
func _input(event: InputEvent) -> void:
	if TimeManager.is_paused() and not is_open:
		return
		
	if event.is_action_pressed("ui_cancel"):
		toggle()
		get_viewport().set_input_as_handled()


func _on_exit_button_pressed() -> void:
	close()

func on_day_passed():
	update_day_display()
	
func update_day_display():
	var current_day = TimeManager.get_current_day()
	var day = current_day["day"]
	var year = current_day["year"]
	
	if current_day_label == null:
		push_error("MainMenu ERROR: current_day_label not assigned in Editor")
		return
		
	current_day_label.text = "Spring %d, Year: %d" % [day, year]

func on_wallet_changed(current_gold):
	
	if current_gold_label == null:
		push_error("MainMenu ERROR: current_gold_label not assigned in Editor")
		
	current_gold_label.text = str(current_gold)

func _on_save_button_pressed() -> void:
	SaveSystem.save_game()
	
func _on_load_button_pressed() -> void:
	SaveSystem.load_game()
