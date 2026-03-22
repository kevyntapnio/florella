extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	InventorySystem.add_item("daisy_seed", 9)
	InventorySystem.add_item("daisy", 6)
