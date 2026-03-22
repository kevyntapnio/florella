extends CanvasLayer

var slots: Array = []

func _ready():
	Hotbar.selected_changed.connect(on_selected_changed)
	
	var hbox = $MarginContainer/HotbarPanel/HBoxContainer
	if hbox:
		slots = hbox.get_children()
	else:
		print("HOTBAR_UI ERROR: Hbox not found")
	
	## ---- Defer call so scene can fully initialize ---- ### 
	on_selected_changed.call_deferred(Hotbar.selected_index)
	
func on_selected_changed(selected_index):
	for slot in slots:
		if slot.slot_index == selected_index:
			slot.highlight.show()
		else:
			slot.highlight.hide()
	print("selection update called", selected_index)
