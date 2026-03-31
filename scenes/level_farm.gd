extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GridManager.set_tilemap($World/GroundTileMap)
	TargetingSystem.set_tilemap($World/GroundTileMap)
	
	InventorySystem.add_item("basic_hoe", 1)
	InventorySystem.add_item("basic_watering_can", 1)
	InventorySystem.add_item("tulip_bulb", 99)
	InventorySystem.add_item("daisy_seed", 99)
	InventorySystem.add_item("ranunculus_corms", 99)
