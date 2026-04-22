extends Node

func _add_items_to_inventory():
	
	InventorySystem.add_item("basic_watering_can", 1)
	InventorySystem.add_item("basic_hoe", 1)
	InventorySystem.add_item("worn_table", 3)
	PlayerGlobalStats.add_to_wallet(5000)
