extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	InventorySystem.add_item("daisy_seed", 40)
	InventorySystem.add_item("daisy", 3)
	
	InventorySystem.add_item("tulip_bulb", 40)
	InventorySystem.add_item("tulip", 3)
