extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print(InventorySystem)
	
	InventorySystem.add_item("daisy_seed", 9)
	InventorySystem.add_item("daisy", 6)
	print(InventorySystem.get_inventory())
