extends SlotContainer
class_name SellContainer

var container_ui
var sell_container: SlotContainer

var max_slots: int = 5

func _ready() -> void:
	initialize(max_slots)
	
