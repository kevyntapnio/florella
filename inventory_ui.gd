extends CanvasLayer

@export var grid_container: GridContainer
@export var slot_scene: PackedScene

var selected_index = -1
var is_open = false

signal selection_changed(selected_index)
	
func _ready():  
	visible = false
	create_slots()
		
func create_slots():
	for i in range(30):
		var slot = slot_scene.instantiate()
		grid_container.add_child(slot)
		slot.slot_index = i
		
		## Connect to InventoryUI
		slot.slot_clicked.connect(on_slot_clicked)
		selection_changed.emit(selected_index)	
		
func toggle():
	is_open = !is_open
	visible = is_open
	
	#if is_open:
	#	TimeManager.pause_time(self)
	#else:
	#	TimeManager.resume_time(self)
	
	get_tree().paused = is_open

func _input(event: InputEvent) -> void:
	
	if Input.is_action_just_pressed("inventory"):
		toggle()
		get_viewport().set_input_as_handled()

func on_slot_clicked(slot_index):
	
	if selected_index == -1:
		selected_index = slot_index
	else:
		if slot_index == selected_index:
			selected_index = -1  ## remove highlight
		else:
			InventorySystem.swap_items(selected_index, slot_index)
			selected_index = -1
		
	selection_changed.emit(selected_index)
	
