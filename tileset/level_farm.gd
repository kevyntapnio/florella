extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print(InventorySystem)
	
	InventorySystem.add_item("daisy_seed", 40)
	InventorySystem.add_item("daisy", 3)
