extends CanvasLayer

@onready var panel = $Control/Panel
@onready var control = $Control
@onready var item_name_label = $Control/Panel/MainMargin/ItemInfo/Name
@onready var description_label = $Control/Panel/MainMargin/ItemInfo/Description

var current_item:= false

var item_name = ""
var description = ""

var enabled:= true

var pos_offset: Vector2 = Vector2(8, 8)

func _ready() -> void:
	visible = false
	layer = 15
	
	
func _process(delta: float) -> void:
	if not visible:
		return
	
	await get_tree().process_frame
	update_tooltip_position()
	
func update_tooltip_position():
	var mouse_pos = get_viewport().get_mouse_position()
	var screen_size = get_viewport().get_visible_rect().size
	
	var tooltip_size = panel.size
	
	var final_pos = mouse_pos + pos_offset
	
	if final_pos.x + tooltip_size.x > screen_size.x:
		final_pos.x = mouse_pos.x - pos_offset.x - tooltip_size.x
		
	if mouse_pos.y + pos_offset.y + tooltip_size.y > screen_size.y: 
		final_pos.y = mouse_pos.y - pos_offset.y - tooltip_size.y
		
	control.position = final_pos.round()
	
	#control.position = get_viewport().get_mouse_position() + pos_offset

func show_tooltip(item):
	if not is_inside_tree() or not control:
		return
		
	if not enabled:
		return
		
	if item == null:
		return
	
	item_name_label.text = item["name"]
	description_label.text = item["description"]
	
	current_item = true
	visible = true
	
func remove_tooltip():
	
	current_item = false
	visible = false
	
func _input(event: InputEvent) -> void:
	
	if event.is_action_pressed("toggle_tooltip"):
		enabled = !enabled
		
		if enabled and current_item:
			show()
		else:
			hide()
 		
